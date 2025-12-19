import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_course_2/services/auth/auth_service.dart';
import 'package:flutter_course_2/helpers/note_preview_generator.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object> get props => [query];
}

class SearchFilterChanged extends SearchEvent {
  final String filterType;
  const SearchFilterChanged(this.filterType);
  @override
  List<Object> get props => [filterType];
}

class SearchLoadNotes extends SearchEvent {}

// States
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<CloudNote> results;
  final String query;
  final String activeFilter;

  const SearchLoaded({
    required this.results,
    required this.query,
    this.activeFilter = 'Text',
  });

  @override
  List<Object> get props => [results, query, activeFilter];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final NoteRepository _repository;
  List<CloudNote> _allNotesCache = [];
  StreamSubscription? _notesSubscription;

  SearchBloc(this._repository) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFilterChanged>(_onFilterChanged);
    _initialize();
  }

  void _initialize() async {
    final user = AuthService.firebase().currentUser;
    if (user != null) {
      // Ensure user is set in local DB
      await _repository.getOrCreateUser(email: user.email);

      _notesSubscription = _repository.allNotes.listen((notes) {
        // Repository now returns List<CloudNote>
        _allNotesCache = notes;
      });
    }
  }

  void _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    final query = event.query.toLowerCase();
    String currentFilter = 'Text';
    if (state is SearchLoaded) {
      currentFilter = (state as SearchLoaded).activeFilter;
    }

    final results = _performSearch(query, currentFilter);
    emit(SearchLoaded(results: results, query: event.query, activeFilter: currentFilter));
  }

  void _onFilterChanged(SearchFilterChanged event, Emitter<SearchState> emit) {
    String currentQuery = '';
    if (state is SearchLoaded) {
      currentQuery = (state as SearchLoaded).query;
    }

    if (currentQuery.isNotEmpty) {
      final results = _performSearch(currentQuery, event.filterType);
      emit(SearchLoaded(results: results, query: currentQuery, activeFilter: event.filterType));
    } else {
      emit(SearchInitial());
    }
  }

  List<CloudNote> _performSearch(String query, String filterType) {
    return _allNotesCache.where((note) {
      final titleMatch = note.title.toLowerCase().contains(query);
      final content = NotePreviewGenerator.getPreview(note.contentJson).toLowerCase();
      final contentMatch = content.contains(query);

      if (filterType == 'Tags') {
        return note.tags.isNotEmpty && (titleMatch || contentMatch || note.tags.any((t) => t.toLowerCase().contains(query)));
      }

      return titleMatch || contentMatch;
    }).toList();
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}
