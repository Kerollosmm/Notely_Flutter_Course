import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/notes/note_list_view.dart';
import 'package:flutter_course_2/page/setting_screen.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_course_2/notes/search_bar.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> with TickerProviderStateMixin {
  late final NoteRepository _noteRepository;
  late final Future<void> _initFuture;

  String get userId => AuthService.firebase().currentUser!.id;
  String get userEmail => AuthService.firebase().currentUser!.email;

  final TextEditingController _searchController = TextEditingController();
  List<DatabaseNote> _allNotes = [];

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    _noteRepository = NoteRepository();
    _initFuture = _initRepository();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    super.initState();
  }

  Future<void> _initRepository() async {
    await _noteRepository.open();
    await _noteRepository.getOrCreateUser(email: userEmail);
    // Initial sync
    _noteRepository.sync(userEmail: userEmail, userUid: userId);
  }

  Future<void> _refresh() async {
    await _noteRepository.sync(userEmail: userEmail, userUid: userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
            icon: Icon(Icons.settings, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: StreamBuilder<List<DatabaseNote>>(
                      stream: _noteRepository.allNotes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            _allNotes.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        if (snapshot.hasData) {
                          _allNotes = snapshot.data!;

                          // Filter out locally deleted notes (they shouldn't be in the stream usually, but just in case)
                          // Also filter by search query
                          final query = _searchController.text.toLowerCase();
                          final filteredNotes = _allNotes.where((note) {
                            if (note.syncStatus == SyncStatus.deletedLocally) {
                              return false;
                            }

                            String plainText;
                            try {
                              final delta = jsonDecode(note.contentJson);
                              final doc = Document.fromJson(delta);
                              plainText = doc.toPlainText().toLowerCase();
                            } catch (e) {
                              plainText = note.contentJson.toLowerCase();
                            }
                            // Search in content (title is derived from content)
                            return plainText.contains(query);
                          }).toList();

                          if (filteredNotes.isEmpty && query.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.note_alt_outlined,
                                    size: 80.sp,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No Notes Yet!',
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Tap the "+" button to create your first note.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (_controller.status == AnimationStatus.dismissed) {
                            _controller.forward();
                          }

                          return FadeTransition(
                            opacity: _animation,
                            child: NoteListView(
                              notes: filteredNotes,
                              onDeleteNote: (note) async {
                                await _noteRepository.deleteNote(id: note.id);
                              },
                              onTap: (note) {
                                Navigator.of(context).pushNamed(
                                  createOrUpdateNoteRoute,
                                  arguments: note,
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
