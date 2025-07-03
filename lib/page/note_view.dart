import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/page/setting_screen.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/utailates/dialogs/logout_dialog.dart';
import 'package:flutter_course_2/notes/note_list_view.dart';
import 'package:flutter_course_2/notes/search_bar.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  final TextEditingController _searchController = TextEditingController();
  List<CloudNote> _allNotes = [];
  List<CloudNote> _filteredNotes = [];

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _searchController.addListener(_filterNotes);
    super.initState();
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _allNotes
          .where((note) =>
              note.title.toLowerCase().contains(query) ||
              note.text.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterNotes);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SettingsView()));
            },
            icon: const Icon(Icons.settings, color: Colors.black),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SearchBarWidget(controller: _searchController),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<Iterable<CloudNote>>(
                stream: _notesService.allNote(ownerUserId: userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allNotes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData) {
                    _allNotes = snapshot.data!.toList();
                    // Apply filter right away
                    final query = _searchController.text.toLowerCase();
                    _filteredNotes = _allNotes
                        .where((note) =>
                            note.title.toLowerCase().contains(query) ||
                            note.text.toLowerCase().contains(query))
                        .toList();

                    if (_allNotes.isEmpty) {
                       return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No Notes Yet!',
                              style: TextStyle(fontSize: 22, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                             Text(
                              'Tap the "+" button to create your first note.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return NoteListView(
                      notes: _filteredNotes,
                      onDeleteNote: (note) async {
                        await _notesService.deleteNotes(documentId: note.documentId);
                      },
                      onTap: (note) {
                        Navigator.of(context).pushNamed(
                          createOrUpdateNoteRoute,
                          arguments: note,
                        );
                      },
                    );
                  } else {
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
