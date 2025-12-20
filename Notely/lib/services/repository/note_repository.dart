import 'dart:async';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/sync/sync_service.dart';

class NoteRepository {
  final NotesService _localDb;
  final SyncService _syncService;

  static NoteRepository? _shared;
  factory NoteRepository({
    NotesService? localDb,
    SyncService? syncService,
  }) {
    if (localDb != null || syncService != null) {
      return NoteRepository._sharedInstance(
        localDb: localDb,
        syncService: syncService,
      );
    }
    return _shared ??= NoteRepository._sharedInstance();
  }

  NoteRepository._sharedInstance({
    NotesService? localDb,
    SyncService? syncService,
  })  : _localDb = localDb ?? NotesService(),
        _syncService = syncService ?? SyncService();

  Stream<List<DatabaseNote>> get allNotes => _localDb.allNotes;

  Stream<List<DatabaseNote>> get favoriteNotes => _localDb.favoriteNotes;

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

  Future<DatabaseNote> toggleFavorite({required DatabaseNote note}) async {
    return await _localDb.toggleFavorite(note: note);
  }

  Future<void> deleteNote({required String id}) async {
    await _localDb.deleteNote(id: id);
  }

  Future<void> sync({required String userEmail, required String userUid}) =>
      _syncService.sync(userEmail: userEmail, userUid: userUid);

  Future<DatabaseNote> getNote({required String id}) =>
      _localDb.getNote(id: id);
}