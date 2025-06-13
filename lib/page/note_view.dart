import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:path/path.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  DatabaseNote? _note;

  late final NoteServices _noteServices;

  late final TextEditingController _textController;

  @override
  void initState() {
    _noteServices = NoteServices();
    _textController = TextEditingController();
    _noteServices.open();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _noteServices.updateNote(note: note, Text: text);
  }

  void _setUpTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;

    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthSeries.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteServices.getUser(email: email);

    return await _noteServices.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _noteServices.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      _noteServices.updateNote(note: note, Text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New note')),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setUpTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
