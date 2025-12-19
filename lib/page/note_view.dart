import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/notes/note_list_view.dart';
import 'package:flutter_course_2/page/setting_screen.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/notes/search_bar.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> with TickerProviderStateMixin {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  final TextEditingController _searchController = TextEditingController();
  // _allNotes is kept to help manage the initial loading indicator state.
  List<CloudNote> _allNotes = [];

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    // We no longer need a listener on the controller here,
    // as we'll use the onChanged callback in the SearchBarWidget.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    super.initState();
  }

  // The _filterNotes method is no longer needed because filtering will happen inside the build method.

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
        title: Text('Notes',
            style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const SettingsView()));
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              // Using onChanged to call setState will trigger a rebuild,
              // which is the correct way to handle UI updates on user input.
              onChanged: (_) {
                setState(() {});
              },
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: StreamBuilder<Iterable<CloudNote>>(
                stream: _notesService.allNote(ownerUserId: userId),
                builder: (context, snapshot) {
                  // This condition shows a spinner only on the very first load.
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _allNotes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData) {
                    // Update the complete list of notes from the stream.
                    _allNotes = snapshot.data!.toList();

                    // Perform filtering locally. This does not call setState and is safe.
                    final query = _searchController.text.toLowerCase();
                    final filteredNotes = _allNotes.where((note) {
                      final title = note.title.toLowerCase();
                      String plainText;
                      try {
                        final delta = jsonDecode(note.text);
                        final doc = Document.fromJson(delta);
                        plainText = doc.toPlainText().toLowerCase();
                      } catch (e) {
                        plainText = note.text.toLowerCase();
                      }
                      return title.contains(query) || plainText.contains(query);
                    }).toList();

                    if (_allNotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_alt_outlined,
                                size: 80.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                            SizedBox(height: 16.h),
                            Text(
                              'No Notes Yet!',
                              style: TextStyle(
                                  fontSize: 22.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Tap the "+" button to create your first note.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Start the animation only when the list first appears.
                    if (_controller.status == AnimationStatus.dismissed) {
                      _controller.forward();
                    }
                    
                    return FadeTransition(
                      opacity: _animation,
                      child: NoteListView(
                        notes: filteredNotes, // Pass the filtered list to the UI.
                        onDeleteNote: (note) async {
                          await _notesService.deleteNotes(
                              documentId: note.documentId);
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
                    // Fallback for when snapshot has no data but is not in a waiting state.
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
