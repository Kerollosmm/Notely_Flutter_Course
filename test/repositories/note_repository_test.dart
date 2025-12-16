import 'package:flutter_course_2/repositories/note_repository.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'note_repository_test.mocks.dart';

@GenerateMocks([NotesService])
void main() {
  late NoteRepository repository;
  late MockNotesService mockNotesService;

  setUp(() {
    mockNotesService = MockNotesService();
    repository = NoteRepository(localService: mockNotesService);
  });

  group('NoteRepository', () {
    final user = DatabaseUser(id: 1, email: 'test@test.com');
    final note = DatabaseNote(
      id: 1,
      userId: 1,
      text: 'test',
      syncStatus: 1,
      lastModified: 1000,
    );

    test('getNotes fetches from local service', () async {
      when(mockNotesService.getAllNotes()).thenAnswer((_) async => [note]);

      final notes = await repository.getNotes(owner: user);

      expect(notes.length, 1);
      expect(notes.first, note);
      verify(mockNotesService.getAllNotes()).called(1);
    });

    test('createNote calls local service', () async {
      when(mockNotesService.createNote(owner: user))
          .thenAnswer((_) async => note);

      final result = await repository.createNote(owner: user);

      expect(result, note);
      verify(mockNotesService.createNote(owner: user)).called(1);
    });

    test('updateNote calls local service', () async {
      when(mockNotesService.updateNote(
        note: note,
        text: 'updated',
      )).thenAnswer((_) async => note);

      final result = await repository.updateNote(note: note, text: 'updated');

      expect(result, note);
      verify(mockNotesService.updateNote(note: note, text: 'updated')).called(1);
    });

    test('deleteNote calls local service', () async {
        when(mockNotesService.deleteNote(id: 1)).thenAnswer((_) async => {});

        await repository.deleteNote(id: 1);

        verify(mockNotesService.deleteNote(id: 1)).called(1);
    });
  });
}
