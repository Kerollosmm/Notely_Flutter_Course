import 'dart:async';
import 'dart:convert';
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

  /// Parses the Quill Delta JSON and returns the first line of text as the title.
  String _extractTitle(String contentJson) {
    if (contentJson.isEmpty) return 'Untitled';
    try {
      final List<dynamic> delta = jsonDecode(contentJson);
      final buffer = StringBuffer();

      for (final op in delta) {
        if (op is Map<String, dynamic> && op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is String) {
            buffer.write(insert);
          }
        }
      }

      final text = buffer.toString();
      if (text.trim().isEmpty) {
        return 'Untitled';
      }

      final firstLine = text.split('\n').first.trim();
      return firstLine.isEmpty ? 'Untitled' : firstLine;
    } catch (e) {
      dev.log('Error parsing contentJson for title: $e');
      return 'Untitled';
    }
  }

  Future<void> sync({
    required String userEmail,
    required String userUid,
  }) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        dev.log('No internet connection. Skipping sync.');
        return;
      }

      dev.log('Starting sync for $userEmail...');

      // 1. Ensure local user exists and get ID
      final dbUser = await _localDb.getOrCreateUser(email: userEmail);
      final localUserId = dbUser.id;

      // 2. Push Dirty Notes (Batch)
      final dirtyNotes = await _localDb.getNotesWithStatus(SyncStatus.dirty);

      // Filter for current user
      final userDirtyNotes = dirtyNotes.where((n) => n.userId == localUserId).toList();

      if (userDirtyNotes.isNotEmpty) {
        final batch = _remoteDb.getBatch();
        final List<(String id, SyncStatus status, String? remoteId)> localUpdates = [];

        for (final note in userDirtyNotes) {
          final title = _extractTitle(note.contentJson);

          if (note.remoteId == null) {
            // Create New
            final newRemoteId = _remoteDb.generateNewDocId();
            _remoteDb.batchSet(
              batch: batch,
              documentId: newRemoteId,
              ownerUserId: userUid,
              contentJson: note.contentJson,
              lastModified: Timestamp.fromDate(note.lastModified),
              title: title,
              category: note.category,
              tags: note.tags,
            );
            localUpdates.add((note.id, SyncStatus.synced, newRemoteId));
          } else {
            // Update Existing
            _remoteDb.batchUpdate(
              batch: batch,
              documentId: note.remoteId!,
              contentJson: note.contentJson,
              lastModified: Timestamp.fromDate(note.lastModified),
              title: title,
              category: note.category,
              tags: note.tags,
            );
             localUpdates.add((note.id, SyncStatus.synced, note.remoteId));
          }
        }

        // Commit Remote Batch
        await _remoteDb.commitBatch(batch);

        // Commit Local Batch
        await _localDb.batchUpdateSyncStatuses(localUpdates);
        dev.log('Pushed ${userDirtyNotes.length} notes.');
      }

      // 3. Push Deleted Notes (Batch)
      final deletedNotes = await _localDb.getNotesWithStatus(
        SyncStatus.deletedLocally,
      );
      final userDeletedNotes = deletedNotes.where((n) => n.userId == localUserId).toList();

      if (userDeletedNotes.isNotEmpty) {
        final batch = _remoteDb.getBatch();
        for (final note in userDeletedNotes) {
           if (note.remoteId != null) {
             _remoteDb.batchDelete(batch: batch, documentId: note.remoteId!);
           }
        }
        await _remoteDb.commitBatch(batch);

        // Purge locally one by one (or could be batch if NotesService supported it, but simple loop is fine for purge as it's just local delete)
        // Actually, let's just purge them.
        for (final note in userDeletedNotes) {
          await _localDb.purgeNote(id: note.id);
        }
        dev.log('Deleted ${userDeletedNotes.length} notes.');
      }

      // 4. Pull Changes
      final prefs = await SharedPreferences.getInstance();
      final lastSyncedMillis = prefs.getInt('$_lastSyncedKey$userUid') ?? 0;
      final lastSynced = Timestamp.fromMillisecondsSinceEpoch(lastSyncedMillis);

      final remoteNotes = await _remoteDb.getNotesModifiedAfter(
        ownerUserId: userUid,
        lastSynced: lastSynced,
      );

      if (remoteNotes.isNotEmpty) {
        // Optimization: Fetch all local notes once
        final allLocalNotes = await _localDb.getAllNotes();
        // Create map for O(1) lookup: RemoteID -> DatabaseNote
        // Only include notes that have a remoteId
        final localNoteMap = {
          for (var n in allLocalNotes)
            if (n.remoteId != null) n.remoteId!: n
        };

        final List<DatabaseNote> notesToUpsert = [];

        for (final remoteNote in remoteNotes) {
          final localNote = localNoteMap[remoteNote.documentId];

          if (localNote != null) {
            // Conflict Resolution: Local Dirty wins (Preserve user edits)
            if (localNote.syncStatus == SyncStatus.dirty) {
              continue;
            }

            // Apply remote update
            notesToUpsert.add(DatabaseNote(
               id: localNote.id,
               userId: localUserId,
               contentJson: remoteNote.contentJson,
               syncStatus: SyncStatus.synced,
               remoteId: remoteNote.documentId,
               lastModified: remoteNote.lastModified.toDate(),
               category: remoteNote.category,
               tags: remoteNote.tags,
            ));
          } else {
            // New note from remote
            notesToUpsert.add(DatabaseNote(
              id: const Uuid().v4(), // Generate new local UUID
              userId: localUserId,
              contentJson: remoteNote.contentJson,
              syncStatus: SyncStatus.synced,
              remoteId: remoteNote.documentId,
              lastModified: remoteNote.lastModified.toDate(),
              category: remoteNote.category,
              tags: remoteNote.tags,
            ));
          }
        }

        if (notesToUpsert.isNotEmpty) {
           await _localDb.batchUpsertNotes(notesToUpsert);
           dev.log('Pulled ${notesToUpsert.length} notes.');
        }
      }

      await prefs.setInt(
        '$_lastSyncedKey$userUid',
        DateTime.now().millisecondsSinceEpoch,
      );
      dev.log('Sync completed successfully.');

    } catch (e) {
      dev.log('Sync failed: $e');
      // In a real app, you might want to rethrow or return a result object.
    }
  }
}
