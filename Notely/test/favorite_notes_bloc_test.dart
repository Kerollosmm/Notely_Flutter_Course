import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_bloc.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_event.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_state.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('FavoriteNotesBloc', () {
    late NoteRepository repository;
    late FavoriteNotesBloc bloc;

    setUp(() {
      repository = MockNoteRepository();
      bloc = FavoriteNotesBloc(repository);
    });

    tearDown(() {
      bloc.close();
    });

    final mockNotes = [
      DatabaseNote(
        id: '1',
        userId: 1,
        contentJson: '{"insert":"Note 1"}',
        syncStatus: SyncStatus.synced,
        remoteId: 'r1',
        lastModified: DateTime.now(),
        isFavorite: true,
      ),
    ];

    test('initial state should be FavoriteNotesStateInitial', () {
      expect(bloc.state, const FavoriteNotesStateInitial());
    });

    blocTest<FavoriteNotesBloc, FavoriteNotesState>(
      'emits [Loading, Loaded] when FavoriteNotesEventLoad is added',
      build: () {
        when(
          () => repository.favoriteNotes,
        ).thenAnswer((_) => Stream.value(mockNotes));
        return bloc;
      },
      act: (bloc) => bloc.add(const FavoriteNotesEventLoad()),
      expect: () => [
        const FavoriteNotesStateLoading(),
        FavoriteNotesStateLoaded(notes: mockNotes),
      ],
    );

    blocTest<FavoriteNotesBloc, FavoriteNotesState>(
      'emits Updated Loaded state when FavoriteNotesEventSearch is added',
      seed: () => FavoriteNotesStateLoaded(notes: mockNotes),
      build: () => bloc,
      act: (bloc) => bloc.add(const FavoriteNotesEventSearch('Note 1')),
      expect: () => [
        FavoriteNotesStateLoaded(notes: mockNotes, searchTerm: 'Note 1'),
      ],
    );

    blocTest<FavoriteNotesBloc, FavoriteNotesState>(
      'emits Updated Loaded state when FavoriteNotesEventFilter is added',
      seed: () => FavoriteNotesStateLoaded(notes: mockNotes),
      build: () => bloc,
      act: (bloc) => bloc.add(const FavoriteNotesEventFilter('Work')),
      expect: () => [
        FavoriteNotesStateLoaded(notes: mockNotes, activeTag: 'Work'),
      ],
    );
  });
}
