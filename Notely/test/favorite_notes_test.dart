import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter/services.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_course_2/services/sync/sync_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncService extends Mock implements SyncService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    return '.';
  });

  group('Favorite Notes Service Tests', () {
    late NotesService notesService;

    setUp(() async {
      notesService = NotesService();
      // NotesService handles database opening internally
      await notesService.getOrCreateUser(email: 'test@example.com');
      await notesService.deleteAllNotes();
    });

    test('Local: favoriteNotes stream should filter notes correctly', () async {
      final user = await notesService.getOrCreateUser(email: 'test@example.com');
      final note1 = await notesService.createNote(owner: user);
      
      // Initially empty
      var favorites = await notesService.favoriteNotes.first;
      expect(favorites.length, 0);
      
      // Toggle favorite
      await notesService.toggleFavorite(note: note1);
      
      favorites = await notesService.favoriteNotes.first;
      expect(favorites.length, 1);
      expect(favorites.first.id, note1.id);
      expect(favorites.first.isFavorite, true);
    });

    test('Cloud: getFavoriteNotes should return only favorites', () async {
      final firestore = FakeFirebaseFirestore();
      final cloudStorage = FirebaseCloudStorage(firestore: firestore);
      final userId = 'user123';
      
      // Create a favorite note
      await firestore.collection('notes').add({
        'user_id': userId,
        'text': 'Note 1',
        'is_favorite': true,
        'last_modified': Timestamp.now(),
      });
      
      // Create a non-favorite note
      await firestore.collection('notes').add({
        'user_id': userId,
        'text': 'Note 2',
        'is_favorite': false,
        'last_modified': Timestamp.now(),
      });

      final favoritesStream = cloudStorage.getFavoriteNotes(ownerUserId: userId);
      final favorites = await favoritesStream.first;
      
      expect(favorites.length, 1);
      expect(favorites.first.isFavorite, true);
    });

    test('Cloud: updateFavoriteStatus should update the field', () async {
      final firestore = FakeFirebaseFirestore();
      final cloudStorage = FirebaseCloudStorage(firestore: firestore);
      
      final docRef = await firestore.collection('notes').add({
        'is_favorite': false,
        'last_modified': Timestamp.now(),
      });

      await cloudStorage.updateFavoriteStatus(
        documentId: docRef.id,
        isFavorite: true,
      );

      final snapshot = await docRef.get();
      expect(snapshot.data()!['is_favorite'], true);
    });

    test('Repository: toggleFavorite should delegate to localDb', () async {
      final repository = NoteRepository(
        syncService: MockSyncService(),
      );
      final user = await repository.getOrCreateUser(email: 'repo@test.com');
      final note = await repository.createNote(owner: user);
      
      expect(note.isFavorite, false);
      
      final updatedNote = await repository.toggleFavorite(note: note);
      expect(updatedNote.isFavorite, true);
      
      final favorites = await repository.favoriteNotes.first;
      expect(favorites.any((n) => n.id == note.id), true);
    });
  });
}