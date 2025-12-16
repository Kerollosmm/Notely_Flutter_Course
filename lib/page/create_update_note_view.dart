import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/repositories/note_repository.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/utailates/generics/get_arguments.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:share_plus/share_plus.dart';

// We'll inject the repository via a provider or simple get_it/singleton accessor later.
// For now, let's assume we can get it or construct it.
// The prompt said "Update the Bloc / State Management to use the new NoteRepository".
// So I should probably rely on a pattern where I can access the repository.
// For now I will initialize it here (or rather, use the Singleton Local Service inside a repository wrapper).

class CreateUpdateNoteView extends StatefulWidget {
  final NoteRepository? noteRepository; // Allow injection
  const CreateUpdateNoteView({Key? key, this.noteRepository}) : super(key: key);

  @override
  _CreateUpdateNoteViewState createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  late final NoteRepository _noteRepository;
  late final quill.QuillController _quillController;
  late final TextEditingController _titleController;
  bool _isToolbarVisible = false;

  @override
  void initState() {
    _noteRepository = widget.noteRepository ?? NoteRepository(localService: NotesService());
    _quillController = quill.QuillController.basic();
    _titleController = TextEditingController();
    super.initState();
  }

  void _contentControllerListener() async {
    final note = _note;
    if (note == null) return;
    final title = _titleController.text; // We might want to store title separately in DB eventually, but for now prompt said "fields: ... title" was in the description but I only added fields required. Wait, checking prompt "Add fields: sync_status, remote_id, last_modified". It also says "database schema includes ... title".
    // Wait, the `DatabaseNote` in `NoteService` I edited DOES NOT have a title field.
    // The previous schema did NOT have a title field either (textColumn only).
    // `FirebaseCloudStorage` had `title`. `NotesService` (SQLite) only had `text`.
    // The prompt: "Add fields: sync_status, remote_id, last_modified".
    // And "Ensure the local DB can store JSON content (for Rich Text) instead of plain string."
    // It seems I missed `title` in my `NoteService` update if it was expected.
    // Prompt says: "The local SQLite database (`notes_v2.db`) schema includes `sync_status` ... `title` ... columns." in MEMORY.
    // The USER request says: "Database Schema Update: Modify ... Add fields: sync_status, remote_id, last_modified". It DOES NOT explicitly say "Add title".
    // BUT `CloudNote` has title. `DatabaseNote` did not.
    // If I am to support title, I should add it.
    // However, usually RichText notes (like Google Docs) store the title inside the document or as a separate metadata.
    // Given the UI shows a Title TextField, I should probably store it.
    // I'll store it as part of the JSON or add a column.
    // Let's check `NoteService` again. It only has `text`.
    // If I change the schema now, I need to update tests.
    // I'll stick to storing it in the `text` field (JSON) or assume the first line is title?
    // No, `create_update_note_view.dart` has a separate Title controller.
    // I should probably add `title` column to `DatabaseNote` to match the UI.

    // Let's pause and update `NoteService` to include `title` because it makes sense for a Note app.
    // But strictly following the prompt: "Add fields: sync_status ... remote_id ... last_modified".
    // I will implicitly add `title` to make the app work better, or I can store title in the JSON.
    // Actually, looking at `FirebaseCloudStorage`, it has `title`.
    // I will add `title` to `DatabaseNote`.

    // Wait, I cannot interrupt this file creation easily.
    // I will write this file assuming `DatabaseNote` has `title` (or I will handle it).
    // Let's assume I will go back and add `title` to `NoteService`.

    // ... Actually, I will serialize the content as:
    // { "title": "...", "content": [Delta] }
    // This avoids schema change for now if I want to be strict, but schema change is cleaner.
    // Let's go with Schema change. I will update `NoteService` in the next step.
    // For now, I will write this code assuming `DatabaseNote` will have `title`.
    // OR, I can just not use `title` for now and rely on the text content?
    // No, the UI clearly has a Title field.

    // Let's use `text` column to store JSON:
    // {
    //   "title": "...",
    //   "content": ...
    // }
    // This satisfies "Ensure the local DB can store JSON content".

    final content = _quillController.document.toDelta().toJson();
    final jsonContent = jsonEncode({
        'title': title,
        'content': content
    });

    await _noteRepository.updateNote(
      note: note,
      text: jsonContent,
    );
  }

  void _setupTextControllerListeners() {
    _titleController.removeListener(_contentControllerListener);
    _titleController.addListener(_contentControllerListener);
    _quillController.document.changes.listen((_) {
      _contentControllerListener();
    });
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      try {
        final json = jsonDecode(widgetNote.text);
        _titleController.text = json['title'] ?? '';
        _quillController.document = quill.Document.fromJson(json['content']);
      } catch (e) {
        // Fallback for old plain text notes
        _titleController.text = ''; // No title for old notes?
        _quillController.document = quill.Document()..insert(0, widgetNote.text);
      }
      _setupTextControllerListeners();
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      _setupTextControllerListeners();
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    final dbUser = await _noteRepository.getOrCreateUser(email: email); // Need to expose this in Repo or Service

    final newNote = await _noteRepository.createNote(
      owner: dbUser,
    );
    _note = newNote;
    _setupTextControllerListeners();
    return newNote;
  }

  // Repo needs getOrCreateUser. It's missing in my Repo definition. I'll add it later or access service directly.
  // Accessing service directly for User creation is fine for now as it's Auth related.
  // But wait, `NoteRepository` wrapper was minimal.

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_titleController.text.isEmpty &&
        _quillController.document.isEmpty() &&
        note != null) {
      _noteRepository.deleteNote(id: note.id);
    }
  }

  void _shareNote() {
    final title = _titleController.text;
    final text = _quillController.document.toPlainText();
    final noteContent = '$title\n\n$text';
    if (noteContent.isNotEmpty) {
      Share.share(noteContent);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _toggleToolbar() {
      setState(() {
          _isToolbarVisible = !_isToolbarVisible;
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _shareNote,
            icon: Icon(Icons.share, color: theme.colorScheme.onBackground),
          )
        ],
      ),
      body: FutureBuilder<DatabaseNote>(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _note == null) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            );
          }

          return Column(
            children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: quill.QuillEditor.basic(
                            controller: _quillController,
                            config: const quill.QuillEditorConfig(
                                placeholder: 'Start writing...',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Collapsible Toolbar
                if (_isToolbarVisible)
                    Container(
                        color: theme.colorScheme.surface,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: quill.QuillSimpleToolbar(
                                controller: _quillController,
                                config: const quill.QuillSimpleToolbarConfig(
                                    showFontFamily: false,
                                    showFontSize: false, // Using H1/H2 instead
                                    toolbarIconAlignment: WrapAlignment.start,
                                    multiRowsDisplay: false,
                                ),
                            ),
                        ),
                    ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _toggleToolbar,
          child: Icon(_isToolbarVisible ? Icons.keyboard_arrow_down : Icons.format_paint),
      ),
    );
  }
}

// Extension to help with creating user if needed or we update repo
extension NoteRepoUserHelper on NoteRepository {
    Future<DatabaseUser> getOrCreateUser({required String email}) async {
        // This is a bit hacky, normally Repo should expose this.
        // Accessing the private field via dynamic or just creating a new Service instance?
        // Ideally we update NoteRepository to include this method.
        // For now, I'll use a direct Service call in the widget for this specific startup logic.
        return NotesService().getOrCreateUser(email: email);
    }
}
