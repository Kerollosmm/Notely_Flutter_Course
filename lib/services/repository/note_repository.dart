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

  Stream<List<DatabaseNote>> get favoriteNotes =>
      _localDb.allNotes.map((notes) => notes.where((n) => n.isFavorite).toList());

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

  Future<void> toggleFavorite({required String id}) =>
      _localDb.toggleFavorite(id: id);

  Future<List<DatabaseNote>> searchNotes({required String query}) async {
    final all = await _localDb.getAllNotes(); // Or use stream if we want reactive search
    // Naive search implementation: check if contentJson contains query
    // Ideally we would parse JSON to plain text first, or use FTS5 in SQLite.
    // For now, simple containment.
    if (query.isEmpty) return [];

    // Note: contentJson is a JSON string. Searching inside it is crude but works for basic implementation.
    // Ideally, we extract text from Quill Delta.
    return all.where((note) {
      return note.contentJson.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
