import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'dart:developer' as dev;

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
      if (note.userId != localUserId) continue; // Safety check

      try {
        if (note.remoteId == null) {
          // Create new in cloud
          final cloudNote = await _remoteDb.createNewNote(
            ownerUserId: userUid,
            contentJson: note.contentJson,
            lastModified: Timestamp.fromDate(note.lastModified),
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
        // Hard delete locally
        await _localDb.purgeNote(id: note.id);
      } catch (e) {
        dev.log('Failed to delete note ${note.id}: $e');
      }
    }

    // 4. Pull Changes
    final prefs = await SharedPreferences.getInstance();
    final lastSyncedMillis = prefs.getInt('$_lastSyncedKey$userUid') ?? 0;
    final lastSynced = Timestamp.fromMillisecondsSinceEpoch(lastSyncedMillis);

    // Fetch remote notes modified after last sync
    // If it's first sync (0), this gets ALL notes.
    try {
      final remoteNotes = await _remoteDb.getNotesModifiedAfter(
        ownerUserId: userUid,
        lastSynced: lastSynced,
      );

      for (final remoteNote in remoteNotes) {
        // Find if we have this note locally by remoteId
        // I need a method `getNoteByRemoteId` in NotesService?
        // Or I can just iterate.
        // Efficient way: NotesService needs `getNoteByRemoteId`.
        // I'll implement it or just use `getAllNotes` (not efficient).
        // Let's add `getNoteByRemoteId` to NotesService.

        // Wait, I can't easily modify NotesService again and again.
        // I'll use `getNotesWithStatus` which I already added? No.
        // I'll use `getAllNotes` and filter in memory for now (MVP).
        final allLocalNotes = await _localDb.getAllNotes();
        DatabaseNote? localNote;
        try {
          localNote = allLocalNotes.firstWhere(
            (n) => n.remoteId == remoteNote.documentId,
          );
        } catch (_) {}

        if (localNote != null) {
          // Conflict resolution: Remote wins if newer (which it is, by query definition sort of)
          // Actually, if local is DIRTY, we have a conflict.
          if (localNote.syncStatus == SyncStatus.dirty) {
            // Conflict!
            // Strategy: Keep Local (user just edited), ignore Remote update for now?
            // Or Duplicate?
            // Simple: Local wins. Do nothing. Next push will overwrite remote.
            continue;
          }

          await _localDb.upsertLocalNote(
            id: localNote.id,
            userId: localUserId,
            contentJson: remoteNote.contentJson,
            remoteId: remoteNote.documentId,
            lastModified: remoteNote.lastModified.toDate(),
            syncStatus: SyncStatus.synced,
          );
        } else {
          // New note from remote
          // We need to generate a local ID for it?
          // We can use UUID.
          // Note: `upsertLocalNote` takes an ID.
          // If I don't have a local ID, I generate one.
          // Check if I already have a note with the SAME ID?
          // Remote ID is not Local ID.
          // So I generate new UUID.
          // WAIT. If I uninstall and reinstall, I pull notes.
          // They will have remote IDs but no local IDs.
          // I generate new local IDs for them.

          // But what if I have a local note that hasn't synced yet,
          // and I pull a note that IS that note (somehow)? Unlikely with UUIDs.

          // One Edge Case: If I use `remoteId` as `id`?
          // No, local `id` is UUID, remote `id` is Firestore ID.

          await _localDb.upsertLocalNote(
            id: const Uuid().v4(), // Generate new local ID
            userId: localUserId,
            contentJson: remoteNote.contentJson,
            remoteId: remoteNote.documentId,
            lastModified: remoteNote.lastModified.toDate(),
            syncStatus: SyncStatus.synced,
          );
        }
      }

      // Update last synced time
      await prefs.setInt(
        '$_lastSyncedKey$userUid',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      dev.log('Pull failed: $e');
    }
  }
}
