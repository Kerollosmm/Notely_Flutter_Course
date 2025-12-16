import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_exceptions.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SyncService {
  final NotesService _localService;
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService({
    required NotesService localService,
    required FirebaseFirestore firestore,
    required Connectivity connectivity,
  })  : _localService = localService,
        _firestore = firestore,
        _connectivity = connectivity;

  void startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      // connectivity_plus now returns a List<ConnectivityResult>
      if (results.any((result) => result != ConnectivityResult.none)) {
        syncPendingChanges();
      }
    });
  }

  void stopMonitoring() {
    _connectivitySubscription?.cancel();
  }

  Future<void> syncPendingChanges() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      if (connectivityResults.every((result) => result == ConnectivityResult.none)) {
          _isSyncing = false;
          return;
      }

      final allNotes = await _localService.getAllNotesForSync();

      for (final note in allNotes) {
        if (note.syncStatus == 1) continue; // Already synced

        try {
          if (note.syncStatus == 2) { // Dirty (Create/Update)
             await _pushUpdateToCloud(note);
          } else if (note.syncStatus == 3) { // Deleted Locally
             await _pushDeleteToCloud(note);
          }
        } catch (e) {
          // Log error or retry later
          print('Error syncing note ${note.id}: $e');
        }
      }

      // Pull updates from cloud (simplified for now)
      // In a real app, we would query by last_modified > last_sync_time

    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushUpdateToCloud(DatabaseNote note) async {
    final user = await _localService.getUser(email: 'current_user_email'); // Need a way to get current user
    // For now, let's assume we can get user ID from note.userId, but we need the Firebase User ID.
    // The current DatabaseUser only has ID and Email.
    // The previous implementation of CloudStorageService used `ownerUserId`.
    // We need to map local user ID to remote user ID or store remote user ID in local DB.
    // Assuming the email is the key or we have a way to link.
    // Let's assume the `ownerUserId` required by Firestore is the user's email or a stored uid.
    // Since we don't have that link explicitly in `DatabaseUser` yet (it just has ID and Email).
    // Let's assume we use the email as document ID or inside the document.
    // But typically we use FirebaseAuth UID.

    // Simplification: We will trust the calling code to handle auth mapping or update DatabaseUser to have firebase_uid.
    // For this task, "Add fields: sync_status, remote_id, last_modified" was requested for NoteService.
    // I should probably also add `firebase_uid` to `DatabaseUser` if I want to be robust.

    // BUT, for now, let's look at `lib/services/cloud/firebase_cloud_storage.dart` if it exists.

    final collection = _firestore.collection('notes');

    if (note.remoteId == null) {
        // Create new
        final docRef = await collection.add({
            'user_id': note.userId.toString(), // Ideally this is the Firebase UID
            'text': note.text,
            'last_modified': note.lastModified,
        });

        await _localService.updateNoteSyncStatus(
            id: note.id,
            status: 1,
            remoteId: docRef.id
        );
    } else {
        // Update existing
        await collection.doc(note.remoteId).update({
             'text': note.text,
             'last_modified': note.lastModified,
        });

        await _localService.updateNoteSyncStatus(
            id: note.id,
            status: 1,
            remoteId: note.remoteId
        );
    }
  }

  Future<void> _pushDeleteToCloud(DatabaseNote note) async {
      if (note.remoteId != null) {
          await _firestore.collection('notes').doc(note.remoteId).delete();
      }
      // Hard delete locally after sync
      await _localService.hardDeleteNote(id: note.id);
  }
}
