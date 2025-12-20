import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_course_2/services/crud/note_services.dart';

@immutable
abstract class FavoriteNotesState extends Equatable {
  const FavoriteNotesState();

  @override
  List<Object?> get props => [];
}

class FavoriteNotesStateInitial extends FavoriteNotesState {
  const FavoriteNotesStateInitial();
}

class FavoriteNotesStateLoading extends FavoriteNotesState {
  const FavoriteNotesStateLoading();
}

class FavoriteNotesStateLoaded extends FavoriteNotesState {
  final List<DatabaseNote> notes;
  final String searchTerm;
  final String activeTag;

  const FavoriteNotesStateLoaded({
    required this.notes,
    this.searchTerm = '',
    this.activeTag = 'All',
  });

  @override
  List<Object?> get props => [notes, searchTerm, activeTag];
}

class FavoriteNotesStateError extends FavoriteNotesState {
  final Exception exception;
  const FavoriteNotesStateError(this.exception);

  @override
  List<Object?> get props => [exception];
}
