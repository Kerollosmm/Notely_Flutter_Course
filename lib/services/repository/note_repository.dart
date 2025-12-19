import 'dart:async';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/sync/sync_service.dart';

class NoteRepository {
  final NotesService _localDb;
  final SyncService _syncService;

  static final NoteRepository _shared = NoteRepository._sharedInstance();
  NoteRepository._sharedInstance()
    : _localDb = NotesService(),
      _syncService = SyncService();
  factory NoteRepository() => _shared;

  Stream<List<DatabaseNote>> get allNotes => _localDb.allNotes;

  Future<void> open() async {
    await _localDb.open();
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) =>
      _localDb.getOrCreateUser(email: email);

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    return await _localDb.createNote(owner: owner);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String contentJson,
  }) async {
    return await _localDb.updateNote(note: note, contentJson: contentJson);
  }

  Future<void> deleteNote({required String id}) async {
    await _localDb.deleteNote(id: id);
  }

  Future<void> sync({required String userEmail, required String userUid}) =>
      _syncService.sync(userEmail: userEmail, userUid: userUid);

  Future<DatabaseNote> getNote({required String id}) =>
      _localDb.getNote(id: id);
}
