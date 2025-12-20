import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_course_2/services/sync/sync_service.dart';
import 'package:flutter_course_2/services/crud/crud_exceptions.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncService extends Mock implements SyncService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '.';
        });
  });

  group('NoteRepository Extensions Tests', () {
    late NoteRepository repository;
    late NotesService notesService;

    setUp(() async {
      notesService = NotesService();
      try {
        await notesService.open(dbPath: inMemoryDatabasePath);
      } on DatabaseAlreadyOpenException {}
      await notesService.deleteAllNotes();
      repository = NoteRepository(localDb: notesService, syncService: MockSyncService());
    });

    test('should add and remove tags from a note', () async {
      final user = await repository.getOrCreateUser(email: 'tag@test.com');
      var note = await repository.createNote(owner: user);
      
      expect(note.tags, isEmpty);

      await repository.addTag(noteId: note.id, tagName: 'Work');
      note = await repository.getNote(id: note.id);
      expect(note.tags, contains('work')); // Normalized to lower case

      await repository.addTag(noteId: note.id, tagName: 'Personal');
      note = await repository.getNote(id: note.id);
      expect(note.tags, containsAll(['work', 'personal']));

      await repository.removeTag(noteId: note.id, tagName: 'Work');
      note = await repository.getNote(id: note.id);
      expect(note.tags, isNot(contains('work')));
      expect(note.tags, contains('personal'));
    });

    test('should search notes by content and tags', () async {
      final user = await repository.getOrCreateUser(email: 'search@test.com');
      
      final note1 = await repository.createNote(owner: user);
      await repository.updateNote(note: note1, contentJson: 'Buying groceries');
      
      final note2 = await repository.createNote(owner: user);
      await repository.updateNote(note: note2, contentJson: 'Meeting minutes');
      await repository.addTag(noteId: note2.id, tagName: 'Office');

      // Search by content
      var results = await repository.searchNotes(query: 'groceries');
      expect(results.length, 1);
      expect(results.first.id, note1.id);

      // Search by tag
      results = await repository.searchNotes(query: 'office');
      expect(results.length, 1);
      expect(results.first.id, note2.id);

      // Search case insensitive
      results = await repository.searchNotes(query: 'OFFICE');
      expect(results.length, 1);
      expect(results.first.id, note2.id);
    });
  });
}
