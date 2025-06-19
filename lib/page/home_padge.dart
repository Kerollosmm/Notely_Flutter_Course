import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/Auth_screens/loginpadge.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/notes/note_list_view.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storge.dart';
import 'package:flutter_course_2/utailates/dialogs/logout_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late final FirebaseCloudStorage _noteServices;
  String get userId => AuthSeries.firebase().currentUser!.id!;

  @override
  void initState() {
    _noteServices = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notely',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/noteView');
            },
            icon: const Icon(Icons.add, color: Colors.black),
          ),
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Text(
              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final shouldLogOut = await showLogOutDialog(context);

                if (shouldLogOut) {
                  await AuthSeries.firebase().logOut();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Log Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body:  StreamBuilder(
              stream: _noteServices.allNote(ownerUserId: userId),
              builder: (context, noteSnapshot) {
                if (noteSnapshot.hasData) {
                  final allNotes = noteSnapshot.data as Iterable<CloudNote>;
                  return NoteListView(
                    notes: allNotes,
                    onDelete: (note) async {
                      await _noteServices.deleteNotes(documentId: note.documentId);
                    },
                  );
                } else if (noteSnapshot.hasError) {
                  return Center(child: Text('Error: ${noteSnapshot.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }
}
