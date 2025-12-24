import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class EditorEvent extends Equatable {
  const EditorEvent();
  @override
  List<Object> get props => [];
}

class EditorLoadNote extends EditorEvent {
  final CloudNote? note;
  const EditorLoadNote(this.note);
}

class EditorTitleChanged extends EditorEvent {
  final String title;
  const EditorTitleChanged(this.title);
}

class EditorContentChanged extends EditorEvent {
  final String contentJson;
  const EditorContentChanged(this.contentJson);
}

class EditorAddTag extends EditorEvent {
  final String tag;
  const EditorAddTag(this.tag);
}

class EditorRemoveTag extends EditorEvent {
  final String tag;
  const EditorRemoveTag(this.tag);
}

class EditorSaveNote extends EditorEvent {}

// States
abstract class EditorState extends Equatable {
  const EditorState();
  @override
  List<Object> get props => [];
}

class EditorInitial extends EditorState {}

class EditorLoading extends EditorState {}

class EditorLoaded extends EditorState {
  final CloudNote? originalNote;
  final String title;
  final String contentJson;
  final List<String> tags;
  final bool isDirty;
  final DateTime lastEdited;

  const EditorLoaded({
    this.originalNote,
    required this.title,
    required this.contentJson,
    required this.tags,
    this.isDirty = false,
    required this.lastEdited,
  });

  EditorLoaded copyWith({
    String? title,
    String? contentJson,
    List<String>? tags,
    bool? isDirty,
    DateTime? lastEdited,
  }) {
    return EditorLoaded(
      originalNote: originalNote,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      tags: tags ?? this.tags,
      isDirty: isDirty ?? this.isDirty,
      lastEdited: lastEdited ?? this.lastEdited,
    );
  }

  @override
  List<Object> get props => [title, contentJson, tags, isDirty, lastEdited];
}

class EditorError extends EditorState {
  final String message;
  const EditorError(this.message);
}

class EditorSaved extends EditorState {}

// BLoC
class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final NoteRepository _repository;
  CloudNote? _currentNote;
  Timer? _autoSaveTimer;

  EditorBloc(this._repository) : super(EditorInitial()) {
    on<EditorLoadNote>(_onLoadNote);
    on<EditorTitleChanged>(_onTitleChanged);
    on<EditorContentChanged>(_onContentChanged);
    on<EditorAddTag>(_onAddTag);
    on<EditorRemoveTag>(_onRemoveTag);
    on<EditorSaveNote>(_onSaveNote);
  }

  void _onLoadNote(EditorLoadNote event, Emitter<EditorState> emit) {
    _currentNote = event.note;
    if (_currentNote != null) {
      emit(EditorLoaded(
        originalNote: _currentNote,
        title: _currentNote!.title,
        contentJson: _currentNote!.contentJson,
        tags: List.from(_currentNote!.tags),
        lastEdited: DateTime.now(),
      ));
    } else {
      emit(EditorLoaded(
        title: '',
        contentJson: '[{"insert":"\\n"}]',
        tags: [],
        lastEdited: DateTime.now(),
      ));
    }
  }

  void _onTitleChanged(EditorTitleChanged event, Emitter<EditorState> emit) {
    if (state is EditorLoaded) {
      final currentState = state as EditorLoaded;
      emit(currentState.copyWith(
        title: event.title,
        isDirty: true,
        lastEdited: DateTime.now(),
      ));
      _scheduleAutoSave();
    }
  }

  void _onContentChanged(EditorContentChanged event, Emitter<EditorState> emit) {
    if (state is EditorLoaded) {
      final currentState = state as EditorLoaded;
      emit(currentState.copyWith(
        contentJson: event.contentJson,
        isDirty: true,
        lastEdited: DateTime.now(),
      ));
      _scheduleAutoSave();
    }
  }

  void _onAddTag(EditorAddTag event, Emitter<EditorState> emit) {
    if (state is EditorLoaded) {
      final currentState = state as EditorLoaded;
      final newTags = List<String>.from(currentState.tags)..add(event.tag);
      emit(currentState.copyWith(tags: newTags, isDirty: true));
      _scheduleAutoSave();
    }
  }

  void _onRemoveTag(EditorRemoveTag event, Emitter<EditorState> emit) {
    if (state is EditorLoaded) {
      final currentState = state as EditorLoaded;
      final newTags = List<String>.from(currentState.tags)..remove(event.tag);
      emit(currentState.copyWith(tags: newTags, isDirty: true));
      _scheduleAutoSave();
    }
  }

  Future<void> _onSaveNote(EditorSaveNote event, Emitter<EditorState> emit) async {
    if (state is EditorLoaded) {
      final currentState = state as EditorLoaded;
      try {
        final currentUser = AuthService.firebase().currentUser;
        if (currentUser == null) throw Exception('User not logged in');

        if (_currentNote == null) {
          // Create new
          final owner = await _repository.getOrCreateUser(email: currentUser.email);
          final dbNote = await _repository.createNote(
            owner: owner,
            category: 'Personal', // Default
            tags: currentState.tags,
          );
          // Update content immediately
          final updated = await _repository.updateNote(
            note: dbNote,
            contentJson: currentState.contentJson,
            category: 'Personal',
            tags: currentState.tags,
          );

          // Update _currentNote to prevent creating duplicates on next save
          _currentNote = CloudNote(
            documentId: updated.id,
            ownerUserId: updated.userId.toString(),
            contentJson: updated.contentJson,
            title: currentState.title,
            lastModified: Timestamp.fromDate(updated.lastModified),
            category: updated.category,
            tags: updated.tags,
          );
        } else {
          // Update existing
          // Construct minimal DatabaseNote for ID
          final dbNote = DatabaseNote(
            id: _currentNote!.documentId,
            userId: 0, // Not used for update lookup
            contentJson: '',
            syncStatus: SyncStatus.dirty,
            remoteId: null,
            lastModified: DateTime.now(),
            category: '',
            tags: [],
          );

          await _repository.updateNote(
            note: dbNote,
            contentJson: currentState.contentJson,
            category: 'Personal',
            tags: currentState.tags,
          );
        }

        emit(currentState.copyWith(isDirty: false));
      } catch (e) {
        emit(EditorError(e.toString()));
      }
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      add(EditorSaveNote());
    });
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}
