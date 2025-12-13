import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_course_2/services/cloud/cloud_storage_exceptions.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';

class SyncService {
  final NotesService _localService;
  final FirebaseCloudStorage _remoteService;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  static final SyncService _shared = SyncService._sharedInstance();
  SyncService._sharedInstance()
      : _localService = NotesService(),
        _remoteService = FirebaseCloudStorage(),
        _connectivity = Connectivity();
  factory SyncService() => _shared;

  void startSyncLoop(String userEmail, String userId) { // userId is Firestore UID
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
       // Check if any result in the list indicates connectivity
      bool hasConnection = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

      if (hasConnection) {
        syncNow(userEmail, userId);
      }
    });
  }

  void stopSyncLoop() {
    _connectivitySubscription?.cancel();
  }

  Future<void> syncNow(String userEmail, String remoteUserId) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1. Push Local Changes to Remote
      await _pushLocalChanges(remoteUserId);

      // 2. Pull Remote Changes to Local
      await _pullRemoteChanges(remoteUserId, userEmail);
    } catch (e) {
      print('Sync Error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushLocalChanges(String remoteUserId) async {
    // Get dirty notes
    final allNotes = await _localService.getAllNotesForSync();
    final dirtyNotes = allNotes.where((n) => n.syncStatus == 2 || n.syncStatus == 3);

    for (var note in dirtyNotes) {
      if (note.syncStatus == 3) { // Deleted Locally
        if (note.remoteId != null) {
          try {
            await _remoteService.deleteNotes(documentId: note.remoteId!);
            await _localService.hardDeleteNote(id: note.id);
          } on CouldNotDeleteNoteException {
             // If we can't delete it on remote, it might not exist or we have network error.
             // We should only hard delete local if we are sure it's done or irrelevant.
             // If it's a network error, we should retry later (keep status 3).
             // If it's "not found", we can delete locally.
             // Since our custom exception doesn't distinguish, we have to be careful.
             // For now, let's assume if delete throws, it might be connectivity issue.
             // But if we are in syncNow, we likely have connectivity.
             // Let's rely on standard logic: if it fails, keep it dirty/deletedLocally.
             // EXCEPT if we know it's gone.
             // Ideally we'd check if it exists first or catch specific "not found" error.
             // Without specific error, it's safer to RETRY.
             // BUT to avoid Zombie loop (if it really is gone), we should probably check.
             // For this task, I will leave it to retry.
          } catch (e) {
             // Retry later
          }
        } else {
          await _localService.hardDeleteNote(id: note.id);
        }
      } else if (note.syncStatus == 2) { // Dirty (Created or Updated)
        if (note.remoteId == null) {
          // Create on Remote
          try {
            final cloudNote = await _remoteService.createNewNote(ownerUserId: remoteUserId);
            await _remoteService.updateNotes(
              documentId: cloudNote.documentId,
              text: note.text,
              title: note.title,
            );

            await _localService.updateNoteSyncStatus(
              id: note.id,
              syncStatus: 1, // Synced
              remoteId: cloudNote.documentId,
            );
          } catch (e) {
            // Keep dirty, retry later
          }
        } else {
          // Update Remote
          try {
            await _remoteService.updateNotes(
              documentId: note.remoteId!,
              text: note.text,
              title: note.title,
            );

            await _localService.updateNoteSyncStatus(
              id: note.id,
              syncStatus: 1, // Synced
            );
          } catch (e) {
             // Keep dirty, retry later
          }
        }
      }
    }
  }

  Future<void> _pullRemoteChanges(String remoteUserId, String userEmail) async {
    try {
      final remoteNotes = await _remoteService.getNotes(ownerUserId: remoteUserId);
      final localNotes = await _localService.getAllNotesForSync();

      // Create a map for faster lookup
      final localMap = {for (var n in localNotes) n.remoteId: n};
      localMap.remove(null); // Remove notes with null remoteId (unsynced local notes)

      final user = await _localService.getUser(email: userEmail);

      for (var remoteNote in remoteNotes) {
        final localNote = localMap[remoteNote.documentId];

        if (localNote == null) {
          // New remote note -> Create local
          await _localService.createSyncedNote(
            userId: user.id,
            remoteId: remoteNote.documentId,
            text: remoteNote.text,
            title: remoteNote.title,
            lastModified: DateTime.now().millisecondsSinceEpoch,
          );
        } else {
          // Existing note -> Check conflict
          if (localNote.syncStatus == 1) {
              if (localNote.text != remoteNote.text || localNote.title != remoteNote.title) {
                  await _localService.updateNote(
                      note: localNote,
                      text: remoteNote.text,
                      title: remoteNote.title,
                      syncStatus: 1, // Remain synced
                      lastModified: DateTime.now().millisecondsSinceEpoch,
                  );
              }
          }
        }
      }

      // Handle deletions on remote
      final remoteIds = remoteNotes.map((n) => n.documentId).toSet();
      for (var localNote in localNotes) {
          if (localNote.remoteId != null && !remoteIds.contains(localNote.remoteId)) {
               // Remote deleted it.
               await _localService.hardDeleteNote(id: localNote.id);
          }
      }
    } catch (e) {
      print('Pull Sync Error: $e');
    }
  }
}
