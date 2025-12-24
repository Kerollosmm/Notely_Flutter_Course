import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'dart:developer' as dev;
import 'package:uuid/uuid.dart';

class SyncService {
  final NotesService _localDb;
  final FirebaseCloudStorage _remoteDb;
  final Connectivity _connectivity = Connectivity();

  static const String _lastSyncedKey = 'last_synced_time_';

  static final SyncService _shared = SyncService._sharedInstance();
  SyncService._sharedInstance()
    : _localDb = NotesService(),
      _remoteDb = FirebaseCloudStorage();
  factory SyncService() => _shared;

  Future<void> sync({
    required String userEmail,
    required String userUid,
  }) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      dev.log('No internet connection. Skipping sync.');
      return;
    }

    dev.log('Starting sync for $userEmail...');

    // 1. Ensure local user exists and get ID
    final dbUser = await _localDb.getOrCreateUser(email: userEmail);
    final localUserId = dbUser.id;

    // 2. Push Dirty Notes
    final dirtyNotes = await _localDb.getNotesWithStatus(SyncStatus.dirty);
    for (final note in dirtyNotes) {
      if (note.userId != localUserId) continue;

      try {
        if (note.remoteId == null) {
          // Create new in cloud
          final cloudNote = await _remoteDb.createNewNote(
            ownerUserId: userUid,
            contentJson: note.contentJson,
            lastModified: Timestamp.fromDate(note.lastModified),
            category: note.category,
            tags: note.tags,
          );
          // Update local with remote ID and synced status
          await _localDb.updateNoteSyncStatus(
            id: note.id,
            status: SyncStatus.synced,
            remoteId: cloudNote.documentId,
          );
        } else {
          // Update existing in cloud
          await _remoteDb.updateNotes(
            documentId: note.remoteId!,
            contentJson: note.contentJson,
            lastModified: Timestamp.fromDate(note.lastModified),
            title: '', // Title not in local DB yet, using empty
            category: note.category,
            tags: note.tags,
          );
          await _localDb.updateNoteSyncStatus(
            id: note.id,
            status: SyncStatus.synced,
            remoteId: note.remoteId,
          );
        }
      } catch (e) {
        dev.log('Failed to push note ${note.id}: $e');
      }
    }

    // 3. Push Deleted Notes
    final deletedNotes = await _localDb.getNotesWithStatus(
      SyncStatus.deletedLocally,
    );
    for (final note in deletedNotes) {
      if (note.userId != localUserId) continue;

      try {
        if (note.remoteId != null) {
          await _remoteDb.deleteNotes(documentId: note.remoteId!);
        }
        await _localDb.purgeNote(id: note.id);
      } catch (e) {
        dev.log('Failed to delete note ${note.id}: $e');
      }
    }

    // 4. Pull Changes
    final prefs = await SharedPreferences.getInstance();
    final lastSyncedMillis = prefs.getInt('$_lastSyncedKey$userUid') ?? 0;
    final lastSynced = Timestamp.fromMillisecondsSinceEpoch(lastSyncedMillis);

    try {
      final remoteNotes = await _remoteDb.getNotesModifiedAfter(
        ownerUserId: userUid,
        lastSynced: lastSynced,
      );

      // Optimization: Fetch all local notes once
      final allLocalNotes = await _localDb.getAllNotes();
      // Create map for O(1) lookup: RemoteID -> DatabaseNote
      // Only include notes that have a remoteId
      final localNoteMap = {
        for (var n in allLocalNotes)
          if (n.remoteId != null) n.remoteId!: n
      };

      for (final remoteNote in remoteNotes) {
        final localNote = localNoteMap[remoteNote.documentId];

        if (localNote != null) {
          // Conflict Resolution: Local Dirty wins (Preserve user edits)
          if (localNote.syncStatus == SyncStatus.dirty) {
             continue;
          }

          // Apply remote update
          await _localDb.upsertLocalNote(
            id: localNote.id,
            userId: localUserId,
            contentJson: remoteNote.contentJson,
            remoteId: remoteNote.documentId,
            lastModified: remoteNote.lastModified.toDate(),
            syncStatus: SyncStatus.synced,
            category: remoteNote.category,
            tags: remoteNote.tags,
          );
        } else {
          // New note from remote
          await _localDb.upsertLocalNote(
            id: Uuid().v4(), // Generate new local UUID
            userId: localUserId,
            contentJson: remoteNote.contentJson,
            remoteId: remoteNote.documentId,
            lastModified: remoteNote.lastModified.toDate(),
            syncStatus: SyncStatus.synced,
            category: remoteNote.category,
            tags: remoteNote.tags,
          );
        }
      }

      await prefs.setInt(
        '$_lastSyncedKey$userUid',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      dev.log('Pull failed: $e');
    }
  }
}
