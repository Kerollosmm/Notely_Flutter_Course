import 'dart:async';
import 'package:flutter_course_2/services/crud/note_services.dart';

class NoteRepository {
  final NotesService _localService;

  // Singleton
  static final NoteRepository _shared = NoteRepository._sharedInstance();
  NoteRepository._sharedInstance()
      : _localService = NotesService();
  factory NoteRepository() => _shared;

  // Stream of notes from local DB
  Stream<List<DatabaseNote>> get allNotes => _localService.allNotes;

  // Initialize and load notes
  Future<void> init(String userEmail) async {
    await _localService.open();
    await _localService.getOrCreateUser(email: userEmail);
  }

  Future<DatabaseNote> createNote({required String userEmail}) async {
    final user = await _localService.getUser(email: userEmail);
    final note = await _localService.createNote(owner: user);
    return note;
  }

  Future<void> updateNote({
    required DatabaseNote note,
    required String text,
    required String title,
  }) async {
    await _localService.updateNote(
      note: note,
      text: text,
      title: title,
      syncStatus: 2, // Mark as dirty
    );
  }

  Future<void> deleteNote({required DatabaseNote note}) async {
    await _localService.deleteNote(id: note.id);
  }
}
