import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/utailates/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  _CreateUpdateNoteViewState createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  void _contentControllerListener() async {
    final note = _note;
    if (note == null) return;
    final title = _titleController.text;
    final text = _textController.text;
    await _notesService.updateNotes(
      documentId: note.documentId,
      title: title,
      text: text,
    );
  }

  void _setupTextControllerListeners() {
    _titleController.removeListener(_contentControllerListener);
    _titleController.addListener(_contentControllerListener);
    _textController.removeListener(_contentControllerListener);
    _textController.addListener(_contentControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _textController.text = widgetNote.text;
      _setupTextControllerListeners();
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      _setupTextControllerListeners();
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(
      ownerUserId: userId,
    );
    _note = newNote;
    _setupTextControllerListeners();
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_titleController.text.isEmpty &&
        _textController.text.isEmpty &&
        note != null) {
      _notesService.deleteNotes(documentId: note.documentId);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<CloudNote>(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _note == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Note',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18),
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