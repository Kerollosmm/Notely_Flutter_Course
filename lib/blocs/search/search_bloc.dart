import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
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
  final FirebaseCloudStorage _notesService;
  List<CloudNote> _allNotesCache = [];

  SearchBloc(this._notesService) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFilterChanged>(_onFilterChanged);
    _loadAllNotes();
  }

  Future<void> _loadAllNotes() async {
    try {
      final user = AuthService.firebase().currentUser;
      if (user != null) {
        final notes = await _notesService.getNotes(ownerUserId: user.id);
        _allNotesCache = notes.toList();
      }
    } catch (e) {
      // Handle error silently or state
    }
  }

  void _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    // Filter
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
      // Just change filter state if needed, but usually search starts with query
      // For now, if no query, remain in Initial or Empty
      emit(SearchInitial());
    }
  }

  List<CloudNote> _performSearch(String query, String filterType) {
    return _allNotesCache.where((note) {
      final titleMatch = note.title.toLowerCase().contains(query);
      final content = NotePreviewGenerator.getPreview(note.contentJson).toLowerCase();
      final contentMatch = content.contains(query);

      bool typeMatch = true;
      if (filterType == 'Tags') {
        typeMatch = note.tags.any((t) => t.toLowerCase().contains(query));
        // If filtering by Tags, we strictly look at tags matching the query OR notes having tags?
        // Prompt says: "Found 3 notes with 'design'".
        // Usually, filter chips restrict the scope.
        // "Text" -> Search in title/content
        // "Tags" -> Search in tags
        // "Images" -> Notes with images

        // Let's interpret:
        if (filterType == 'Text') return titleMatch || contentMatch;
        if (filterType == 'Tags') return note.tags.isNotEmpty && (titleMatch || contentMatch || note.tags.any((t) => t.toLowerCase().contains(query)));
        // Simple version:
        return titleMatch || contentMatch;
      }

      return titleMatch || contentMatch;
    }).toList();
  }
}
