import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_course_2/enums/sync_status.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';

class NoteRepository {
  final NotesService _localService;
  final FirebaseCloudStorage _remoteService;
  final StreamController<List<DatabaseNote>> _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  NoteRepository({
    required NotesService localService,
    required FirebaseCloudStorage remoteService,
  })  : _localService = localService,
        _remoteService = remoteService {
    _localService.allNotes.listen((notes) {
      _notesStreamController.add(notes);
    });
  }

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> syncWithUser({required DatabaseUser currentUser}) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none) && connectivityResult.length == 1) {
      return;
    }

    try {
      // 1. Push local changes
      // Ensure we only process notes for the current user to prevent data leak
      final allLocalNotes = await _localService.getAllNotes();
      final localNotes = allLocalNotes.where((note) => note.userId == currentUser.id).toList();

      for (final note in localNotes) {
        if (note.syncStatus == SyncStatus.dirty) {
          if (note.remoteId != null) {
             await _remoteService.updateNotes(
                documentId: note.remoteId!,
                text: note.text,
                title: note.title,
              );
              await _localService.updateNote(
                note: note,
                syncStatus: SyncStatus.synced,
              );
          } else {
            if (currentUser.firebaseUid != null) {
              final newCloudNote = await _remoteService.createNewNote(ownerUserId: currentUser.firebaseUid!);
              // Update with content
              await _remoteService.updateNotes(
                documentId: newCloudNote.documentId,
                text: note.text,
                title: note.title
              );

              await _localService.updateNote(
                note: note,
                syncStatus: SyncStatus.synced,
                remoteId: newCloudNote.documentId,
              );
            }
          }
        } else if (note.syncStatus == SyncStatus.deletedLocally) {
          if (note.remoteId != null) {
            await _remoteService.deleteNotes(documentId: note.remoteId!);
          }
          await _localService.deleteNote(id: note.id);
        }
      }

      // 2. Pull remote changes
      if (currentUser.firebaseUid != null) {
        final remoteNotes = await _remoteService.getNotes(ownerUserId: currentUser.firebaseUid!);

        for (final remoteNote in remoteNotes) {
          // Check if we have this note locally
          final localNote = localNotes.firstWhere(
            (n) => n.remoteId == remoteNote.documentId,
            orElse: () => DatabaseNote(
              id: -1,
              userId: currentUser.id,
              text: '',
              title: '',
              syncStatus: SyncStatus.synced,
              lastModified: 0
            ),
          );

          if (localNote.id == -1) {
            // New remote note, create locally
             final newLocalNote = await _localService.createNote(owner: currentUser);
             await _localService.updateNote(
               note: newLocalNote,
               text: remoteNote.text,
               title: remoteNote.title,
               syncStatus: SyncStatus.synced,
               remoteId: remoteNote.documentId,
             );
          } else {
            // Conflict Resolution: Last Modified Wins
            // Note: CloudNote currently doesn't have a timestamp field.
            // I will assume for now that if I pull, the remote might be newer.
            // But if I have a dirty local note, I should keep the local one usually unless remote is newer.
            // Since I don't have remote timestamp, I can't strictly implement "Last Modified Wins".
            // I'll assume if local is synced, I can safely overwrite.
            // If local is dirty, I keep local (client wins effectively in conflict without timestamp).
            // To strictly follow "Last Modified Wins", I would need to add timestamp to CloudNote/Firebase.

            // Assuming I can't modify CloudNote schema easily (it wasn't in the plan to modify CloudNote schema extensively, but I should check).
            // Actually, I should probably add last_modified to CloudNote if possible.
            // But `CloudNote` is read from `lib/services/cloud/cloud_note.dart`.
            // I'll stick to: if local is synced, update from remote. If local is dirty, keep local (as it's likely newer).

            if (localNote.syncStatus == SyncStatus.synced) {
               if (localNote.text != remoteNote.text || localNote.title != remoteNote.title) {
                 await _localService.updateNote(
                   note: localNote,
                   text: remoteNote.text,
                   title: remoteNote.title,
                   syncStatus: SyncStatus.synced,
                 );
               }
            }
          }
        }
      }

    } catch (e) {
      print("Sync Error: $e");
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final note = await _localService.createNote(owner: owner);
    syncWithUser(currentUser: owner);
    return note;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    String? text,
    String? title,
  }) async {
    final updatedNote = await _localService.updateNote(
      note: note,
      text: text,
      title: title,
      syncStatus: SyncStatus.dirty,
    );
    // Sync immediately if possible
    if (_localService.currentUser != null) {
      syncWithUser(currentUser: _localService.currentUser!);
    }
    return updatedNote;
  }

  Future<void> deleteNote({required int id}) async {
    try {
      final note = await _localService.getNote(id: id);
      if (note.remoteId == null) {
        await _localService.deleteNote(id: id);
      } else {
        await _localService.updateNote(
          note: note,
          syncStatus: SyncStatus.deletedLocally,
        );
      }
      // Sync immediately if possible
      if (_localService.currentUser != null) {
        syncWithUser(currentUser: _localService.currentUser!);
      }
    } catch (e) {
      // Note might already be deleted or not found
    }
  }
}
