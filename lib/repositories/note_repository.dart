import 'package:flutter_course_2/services/crud/note_services.dart';

class NoteRepository {
  final NotesService _localService;
  // TODO: Add SyncService when implemented
  // final SyncService _syncService;

  NoteRepository({
    required NotesService localService,
  }) : _localService = localService;

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final note = await _localService.createNote(owner: owner);
    // TODO: Trigger sync
    return note;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final updatedNote = await _localService.updateNote(note: note, text: text);
    // TODO: Trigger sync
    return updatedNote;
  }

  Future<void> deleteNote({required int id}) async {
    await _localService.deleteNote(id: id);
    // TODO: Trigger sync
  }

  Future<Iterable<DatabaseNote>> getNotes({required DatabaseUser owner}) async {
    // Return local notes immediately
    final notes = await _localService.getAllNotes();
    return notes.where((n) => n.userId == owner.id);

    // TODO: Trigger background sync
  }
}
