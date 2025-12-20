import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_event.dart';
import 'package:flutter_course_2/features/favorite_notes/logic/favorite_notes_state.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';

class FavoriteNotesBloc extends Bloc<FavoriteNotesEvent, FavoriteNotesState> {
  final NoteRepository _repository;
  StreamSubscription<List<DatabaseNote>>? _subscription;

  FavoriteNotesBloc(this._repository)
    : super(const FavoriteNotesStateInitial()) {
    on<FavoriteNotesEventLoad>(_onLoad);
    on<FavoriteNotesEventSearch>(_onSearch);
    on<FavoriteNotesEventFilter>(_onFilter);
    on<FavoriteNotesEventToggleFavorite>(_onToggleFavorite);
    on<FavoriteNotesEventUpdate>(_onUpdate);
  }

  Future<void> _onLoad(
    FavoriteNotesEventLoad event,
    Emitter<FavoriteNotesState> emit,
  ) async {
    emit(const FavoriteNotesStateLoading());
    await _subscription?.cancel();

    _subscription = _repository.favoriteNotes.listen((notes) {
      if (!isClosed) {
        final currentState = state;
        String searchTerm = '';
        String activeTag = 'All';

        if (currentState is FavoriteNotesStateLoaded) {
          searchTerm = currentState.searchTerm;
          activeTag = currentState.activeTag;
        }

        add(
          FavoriteNotesEventUpdate(
            notes: notes,
            searchTerm: searchTerm,
            activeTag: activeTag,
          ),
        );
      }
    });
  }

  void _onUpdate(
    FavoriteNotesEventUpdate event,
    Emitter<FavoriteNotesState> emit,
  ) {
    emit(
      FavoriteNotesStateLoaded(
        notes: event.notes,
        searchTerm: event.searchTerm,
        activeTag: event.activeTag,
      ),
    );
  }

  void _onSearch(
    FavoriteNotesEventSearch event,
    Emitter<FavoriteNotesState> emit,
  ) {
    final currentState = state;
    if (currentState is FavoriteNotesStateLoaded) {
      emit(
        FavoriteNotesStateLoaded(
          notes: currentState.notes,
          searchTerm: event.searchTerm,
          activeTag: currentState.activeTag,
        ),
      );
    }
  }

  void _onFilter(
    FavoriteNotesEventFilter event,
    Emitter<FavoriteNotesState> emit,
  ) {
    final currentState = state;
    if (currentState is FavoriteNotesStateLoaded) {
      emit(
        FavoriteNotesStateLoaded(
          notes: currentState.notes,
          searchTerm: currentState.searchTerm,
          activeTag: event.tag,
        ),
      );
    }
  }

  Future<void> _onToggleFavorite(
    FavoriteNotesEventToggleFavorite event,
    Emitter<FavoriteNotesState> emit,
  ) async {
    try {
      final note = await _repository.getNote(id: event.noteId);
      await _repository.toggleFavorite(note: note);
    } catch (e) {
      if (e is Exception) {
        emit(FavoriteNotesStateError(e));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
