import 'dart:async';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/sync/sync_service.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';

class NoteRepository {
  final NotesService _localDb;
  final SyncService _syncService;

  static final NoteRepository _shared = NoteRepository._sharedInstance();
  NoteRepository._sharedInstance()
    : _localDb = NotesService(),
      _syncService = SyncService();
  factory NoteRepository() => _shared;

  Stream<List<CloudNote>> get allNotes => _localDb.allNotes.map(
        (notes) => notes.map((note) => CloudNote.fromDatabaseNote(note)).toList(),
      );

  Future<void> open() async {
    await _localDb.open();
  }

  Future<void> close() async {
    await _localDb.close();
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) =>
      _localDb.getOrCreateUser(email: email);

  Future<DatabaseNote> createNote({
    required DatabaseUser owner,
    String category = 'Personal',
    List<String> tags = const [],
  }) async {
    return await _localDb.createNote(owner: owner, category: category, tags: tags);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    String? contentJson,
    String? category,
    List<String>? tags,
  }) async {
    return await _localDb.updateNote(
      note: note,
      contentJson: contentJson,
      category: category,
      tags: tags,
    );
  }

  Future<void> deleteNote({required String noteId}) async {
    await _localDb.deleteNote(id: noteId);
  }

  Future<void> sync({required String userEmail, required String userUid}) =>
      _syncService.sync(userEmail: userEmail, userUid: userUid);

  Future<DatabaseNote> getNote({required String id}) =>
      _localDb.getNote(id: id);
}
