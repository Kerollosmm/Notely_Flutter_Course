import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'show ReadContext;
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/enums.dart';
import 'package:flutter_course_2/notes/note_list_view.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/utailates/dialogs/logout_dialog.dart';


class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notes', style: theme.textTheme.headlineMedium),
        actions: [
          PopupMenuButton<MenuAction>(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onPrimaryContainer),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                     const AuthEventsLogOut()
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out', style: theme.textTheme.bodyMedium),
                ),
              ];
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        label: Text('Add Note', style: TextStyle(color: theme.colorScheme.onSecondary)),
        icon: Icon(Icons.add, color: theme.colorScheme.onSecondary),
        // backgroundColor: theme.colorScheme.secondary, // Handled by FAB theme
      ),
      body: StreamBuilder<Iterable<CloudNote>>(
        stream: _notesService.allNote(ownerUserId: userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: theme.textTheme.bodyMedium));
          }
          if (snapshot.hasData) {
            final allNotes = snapshot.data!;
            if (allNotes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_alt_outlined, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'No Notes Yet!',
                      style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the "Add Note" button to create your first note.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              );
            }
            return NoteListView(
              notes: allNotes,
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
            // Should ideally not happen if stream is well-behaved, but handle as empty/loading
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
