import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_course_2/services/crud/note_services.dart';

@immutable
abstract class FavoriteNotesEvent extends Equatable {
  const FavoriteNotesEvent();

  @override
  List<Object?> get props => [];
}

class FavoriteNotesEventLoad extends FavoriteNotesEvent {
  const FavoriteNotesEventLoad();
}

class FavoriteNotesEventSearch extends FavoriteNotesEvent {
  final String searchTerm;
  const FavoriteNotesEventSearch(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

class FavoriteNotesEventFilter extends FavoriteNotesEvent {
  final String tag;
  const FavoriteNotesEventFilter(this.tag);

  @override
  List<Object?> get props => [tag];
}

class FavoriteNotesEventToggleFavorite extends FavoriteNotesEvent {
  final String noteId;
  const FavoriteNotesEventToggleFavorite(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class FavoriteNotesEventUpdate extends FavoriteNotesEvent {
  final List<DatabaseNote> notes;
  final String searchTerm;
  final String activeTag;
  const FavoriteNotesEventUpdate({
    required this.notes,
    required this.searchTerm,
    required this.activeTag,
  });

  @override
  List<Object?> get props => [notes, searchTerm, activeTag];
}
