import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/sync/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sync_service_test.mocks.dart';

// We need to mock Connectivity, Firestore and NotesService
@GenerateMocks([
  NotesService,
  FirebaseFirestore,
  Connectivity,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot
])
void main() {
  late SyncService syncService;
  late MockNotesService mockNotesService;
  late MockFirebaseFirestore mockFirestore;
  late MockConnectivity mockConnectivity;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;

  setUp(() {
    mockNotesService = MockNotesService();
    mockFirestore = MockFirebaseFirestore();
    mockConnectivity = MockConnectivity();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();

    when(mockFirestore.collection('notes')).thenReturn(mockCollection);

    syncService = SyncService(
      localService: mockNotesService,
      firestore: mockFirestore,
      connectivity: mockConnectivity,
    );
  });

  group('SyncService', () {
    test('syncPendingChanges does nothing if offline', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      await syncService.syncPendingChanges();

      verifyNever(mockNotesService.getAllNotesForSync());
    });

    test('syncPendingChanges pushes dirty notes', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final dirtyNote = DatabaseNote(
          id: 1,
          userId: 1,
          text: 'dirty',
          syncStatus: 2,
          lastModified: 1000
      );

      when(mockNotesService.getAllNotesForSync())
          .thenAnswer((_) async => [dirtyNote]);

      // Mock Firestore add
      when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);
      when(mockDocument.id).thenReturn('remote_123');

      // Mock update sync status
      when(mockNotesService.updateNoteSyncStatus(
          id: 1,
          status: 1,
          remoteId: 'remote_123'
      )).thenAnswer((_) async => {});

      // Stub getUser since it's called inside _pushUpdateToCloud to find the user
      when(mockNotesService.getUser(email: 'current_user_email'))
          .thenAnswer((_) async => DatabaseUser(id: 1, email: 'current_user_email'));

      await syncService.syncPendingChanges();

      verify(mockCollection.add(any)).called(1);
      verify(mockNotesService.updateNoteSyncStatus(
          id: 1,
          status: 1,
          remoteId: 'remote_123'
      )).called(1);
    });

    test('syncPendingChanges pushes locally deleted notes', () async {
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      final deletedNote = DatabaseNote(
          id: 1,
          userId: 1,
          text: 'deleted',
          syncStatus: 3,
          remoteId: 'remote_123',
          lastModified: 1000
      );

      when(mockNotesService.getAllNotesForSync())
          .thenAnswer((_) async => [deletedNote]);

      when(mockCollection.doc('remote_123')).thenReturn(mockDocument);
      when(mockDocument.delete()).thenAnswer((_) async => {});

      when(mockNotesService.hardDeleteNote(id: 1)).thenAnswer((_) async => {});

      await syncService.syncPendingChanges();

      verify(mockDocument.delete()).called(1);
      verify(mockNotesService.hardDeleteNote(id: 1)).called(1);
    });
  });
}
