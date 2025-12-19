import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class HomeLoadNotes extends HomeEvent {}

class HomeNotesUpdated extends HomeEvent {
  final List<CloudNote> notes;
  const HomeNotesUpdated(this.notes);
  @override
  List<Object> get props => [notes];
}

class HomeFilterChanged extends HomeEvent {
  final String category;
  const HomeFilterChanged(this.category);
  @override
  List<Object> get props => [category];
}

class HomeDeleteNote extends HomeEvent {
  final String noteId;
  const HomeDeleteNote(this.noteId);
  @override
  List<Object> get props => [noteId];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CloudNote> filteredNotes;
  final List<CloudNote> allNotes;
  final String selectedCategory;

  const HomeLoaded({
    required this.filteredNotes,
    required this.allNotes,
    this.selectedCategory = 'All Notes',
  });

  @override
  List<Object> get props => [filteredNotes, allNotes, selectedCategory];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseCloudStorage _notesService;
  StreamSubscription? _notesSubscription;

  HomeBloc(this._notesService) : super(HomeInitial()) {
    on<HomeLoadNotes>(_onLoadNotes);
    on<HomeNotesUpdated>(_onNotesUpdated);
    on<HomeFilterChanged>(_onFilterChanged);
    on<HomeDeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(HomeLoadNotes event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final user = AuthService.firebase().currentUser;
      if (user == null) {
        emit(const HomeError("User not authenticated"));
        return;
      }

      _notesSubscription?.cancel();
      _notesSubscription = _notesService.allNote(ownerUserId: user.id).listen(
        (notes) {
          add(HomeNotesUpdated(notes.toList()));
        },
        onError: (error) {
          // Handle stream error
        },
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void _onNotesUpdated(HomeNotesUpdated event, Emitter<HomeState> emit) {
    final allNotes = event.notes;
    // Sort by last modified descending
    allNotes.sort((a, b) => b.lastModified.compareTo(a.lastModified));

    String currentCategory = 'All Notes';
    if (state is HomeLoaded) {
      currentCategory = (state as HomeLoaded).selectedCategory;
    }

    final filtered = _filterNotes(allNotes, currentCategory);
    emit(HomeLoaded(
      allNotes: allNotes,
      filteredNotes: filtered,
      selectedCategory: currentCategory
    ));
  }

  void _onFilterChanged(HomeFilterChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final loadedState = state as HomeLoaded;
      final filtered = _filterNotes(loadedState.allNotes, event.category);
      emit(HomeLoaded(
        allNotes: loadedState.allNotes,
        filteredNotes: filtered,
        selectedCategory: event.category,
      ));
    }
  }

  List<CloudNote> _filterNotes(List<CloudNote> notes, String category) {
    if (category == 'All Notes') return notes;
    return notes.where((n) => n.category == category).toList();
  }

  Future<void> _onDeleteNote(HomeDeleteNote event, Emitter<HomeState> emit) async {
    try {
      await _notesService.deleteNotes(documentId: event.noteId);
    } catch (e) {
      // Error handling
    }
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}
