import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/crud/crud_exceptions.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  group('Database Migration Tests', () {
    late NotesService notesService;

    setUp(() async {
      notesService = NotesService();
      try {
        await notesService.open(dbPath: inMemoryDatabasePath);
      } on DatabaseAlreadyOpenException {
        // already open
      }
      await notesService.deleteAllNotes();
    });

    tearDown(() async {});

    test(
      'Migration should add is_favorite column and tagging tables',
      () async {
        final owner = await notesService.getOrCreateUser(
          email: 'migration_test@example.com',
        );
        final note = await notesService.createNote(owner: owner);

        // Verify isFavorite field is present and default is false
        expect(note.isFavorite, false);

        // Verify note has an empty tags list
        expect(note.tags, isEmpty);
      },
    );
  });
}
