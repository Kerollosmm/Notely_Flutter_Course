import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:flutter_course_2/services/crud/crud_exceptions.dart';

// Mock path provider
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('NotesService', () {
    late NotesService service;

    setUpAll(() async {
      // Mock getApplicationDocumentsDirectory
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
        return null;
      });
    });

    setUp(() async {
      service = NotesService();
      await service.open();
    });

    tearDown(() async {
        try {
            await service.deleteAllNotes();
        } catch (e) {
            // ignore
        }
        try {
            await service.deleteUser(email: 'test@test.com');
        } catch (e) {
            // ignore
        }
        await service.close();
    });

    test('Create User', () async {
      final user = await service.createUser(email: 'test@test.com');
      expect(user.email, 'test@test.com');
      expect(user.id, isNotNull);
    });

    test('Create Note', () async {
      final user = await service.createUser(email: 'test@test.com');
      final note = await service.createNote(owner: user);

      expect(note.userId, user.id);
      expect(note.text, '');
      expect(note.syncStatus, 2); // Should be dirty by default
      expect(note.lastModified, isNotNull);
    });

    test('Update Note text updates last_modified and keeps it dirty', () async {
      final user = await service.createUser(email: 'test@test.com');
      final note = await service.createNote(owner: user);

      // Wait a bit to ensure timestamp differs if resolution is high enough (ms)
      await Future.delayed(const Duration(milliseconds: 10));

      final updatedNote = await service.updateNote(
        note: note,
        text: 'New Text'
      );

      expect(updatedNote.text, 'New Text');
      expect(updatedNote.lastModified, greaterThan(note.lastModified));
      expect(updatedNote.syncStatus, 2); // Still dirty
    });

    test('Update Note sync status', () async {
        final user = await service.createUser(email: 'test@test.com');
        final note = await service.createNote(owner: user);

        await service.updateNoteSyncStatus(id: note.id, status: 1, remoteId: 'remote_123');

        final updatedNote = await service.getNote(id: note.id);
        expect(updatedNote.syncStatus, 1);
        expect(updatedNote.remoteId, 'remote_123');
    });

    test('Delete Note marks as deleted_locally (Soft Delete)', () async {
      final user = await service.createUser(email: 'test@test.com');
      final note = await service.createNote(owner: user);

      await service.deleteNote(id: note.id);

      // Since deleteNote removes it from the _notes cache and getAllNotes filter it out,
      // we need to query directly or use a special method to verify it's soft deleted.
      // But let's check if we can fetch it via getNote (which queries by ID)

      final deletedNote = await service.getNote(id: note.id);
      expect(deletedNote.syncStatus, 3); // 3 = Deleted Locally

      // And check getAllNotes doesn't return it
      final allNotes = await service.getAllNotes();
      expect(allNotes.contains(deletedNote), false);
    });

    test('JSON content storage', () async {
        final user = await service.createUser(email: 'test@test.com');
        final note = await service.createNote(owner: user);

        const jsonContent = '{"insert":"hello world"}';
        final updatedNote = await service.updateNote(note: note, text: jsonContent);

        expect(updatedNote.text, jsonContent);
    });
  });
}
