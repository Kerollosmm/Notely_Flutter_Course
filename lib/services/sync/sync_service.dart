import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/repositories/note_repository.dart';

class SyncService {
  final NoteRepository _noteRepository;
  final NotesService _notesService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _autoSyncTimer;

  SyncService({
    required NoteRepository noteRepository,
    required NotesService notesService,
  })  : _noteRepository = noteRepository,
        _notesService = notesService;

  void start() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet)) {

        final currentUser = _notesService.currentUser;
        if (currentUser != null) {
          _noteRepository.syncWithUser(currentUser: currentUser);
        }
      }
    });

    // Also sync periodically if online
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final currentUser = _notesService.currentUser;
      if (currentUser != null) {
        _noteRepository.syncWithUser(currentUser: currentUser);
      }
    });
  }

  void stop() {
    _connectivitySubscription?.cancel();
    _autoSyncTimer?.cancel();
  }
}
