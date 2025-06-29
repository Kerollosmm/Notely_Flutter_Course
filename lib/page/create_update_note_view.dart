import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/utailates/dialogs/cannot_share_emty_note_dialog.dart';
import 'package:flutter_course_2/utailates/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  _CreateUpdateNoteViewState createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  bool _isSaving = false;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _contentControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    // Auto-save on content change
    await _notesService.updateNotes(documentId: note.documentId,text: text);
  }

  void _setupTextControllerListeners() {
    _textController.removeListener(_contentControllerListener);
    _textController.addListener(_contentControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _setupTextControllerListeners(); // Ensure listeners are set up for existing notes
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      _setupTextControllerListeners(); // Ensure listeners for re-opened screen with existing note
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    // For a new note, title and text will be empty initially
    final newNote = await _notesService.createNewNote(ownerUserId: userId,);
    _note = newNote;
    _setupTextControllerListeners(); // Setup listeners for the new note
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNotes(documentId: note.documentId);
    }
  }

  Future<void> _saveNote() async {
    setState(() {
      _isSaving = true;
    });
    final note = _note;
    final text = _textController.text;
    if (note != null) {
      if (text.isNotEmpty) {
        await _notesService.updateNotes(documentId: note.documentId,text: text);
      } else {
        // If both are empty, consider deleting or handling as per app logic (current: delete on dispose)
      }
    }
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note saved!'), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty(); // Delete if both title and text are empty
    // Auto-saving is handled by listeners, explicit save is manual.
    // Consider if a final save is needed here if not relying on auto-save or explicit save.
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_note == null ? 'New Note' : 'Edit Note', style: theme.textTheme.headlineMedium),
        actions: [
          if (_isSaving)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.0, color: theme.colorScheme.onPrimary)),
            )
          else
           
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.colorScheme.onPrimaryContainer),
            tooltip: 'Share Note',
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || (text.isEmpty)) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share("\n\n$text", subject:"Shared Note");
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<CloudNote>(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _note == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          // After future completes, _note should be set. If not (e.g. error before setting), show indicator.
          if (_note == null && snapshot.connectionState != ConnectionState.done) {
             return const Center(child: CircularProgressIndicator());
          }


          // If future is done and note is available (or was already available), build the UI
          // _setupTextControllerListeners(); // Called within createOrGetExistingNote

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                
                  const SizedBox(height: 8),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5), // Improved line spacing
                    keyboardType: TextInputType.multiline,
                    maxLines: null, // Allows infinite lines
                    minLines: 10, // Set a comfortable minimum height
                    decoration: InputDecoration(
                      hintText: 'Start typing your note here...',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: InputBorder.none, // Clean look for content
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}