import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/utailates/generics/get_arguments.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  _CreateUpdateNoteViewState createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView>
    with SingleTickerProviderStateMixin {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final quill.QuillController _quillController;
  late final TextEditingController _titleController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  bool _isToolbarExpanded = false;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _quillController = quill.QuillController.basic();
    _titleController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    super.initState();
  }

  void _contentControllerListener() async {
    final note = _note;
    if (note == null) return;
    final title = _titleController.text;
    final text = jsonEncode(_quillController.document.toDelta().toJson());
    await _notesService.updateNotes(
      documentId: note.documentId,
      title: title,
      text: text,
    );
  }

  void _setupTextControllerListeners() {
    _titleController.removeListener(_contentControllerListener);
    _titleController.addListener(_contentControllerListener);
    _quillController.document.changes.listen((_) {
      _contentControllerListener();
    });
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      try {
        final delta = jsonDecode(widgetNote.text);
        _quillController.document = quill.Document.fromJson(delta);
      } catch (e) {
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
        _quillController.document.isEmpty() &&
        note != null) {
      _notesService.deleteNotes(documentId: note.documentId);
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

  void _toggleToolbar() {
    setState(() {
      _isToolbarExpanded = !_isToolbarExpanded;
    });
    if (_isToolbarExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Widget _buildMinimalToolbar() {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          // Bold button
          _buildToolbarButton(
            icon: Icons.format_bold,
            onPressed: () => _quillController.formatSelection(quill.Attribute.bold),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('bold'),
          ),
          _buildDivider(),
          // Italic button
          _buildToolbarButton(
            icon: Icons.format_italic,
            onPressed: () => _quillController.formatSelection(quill.Attribute.italic),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('italic'),
          ),
          _buildDivider(),
          // Underline button
          _buildToolbarButton(
            icon: Icons.format_underlined,
            onPressed: () => _quillController.formatSelection(quill.Attribute.underline),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('underline'),
          ),
          _buildDivider(),
          // List button
          _buildToolbarButton(
            icon: Icons.format_list_bulleted,
            onPressed: () => _quillController.formatSelection(quill.Attribute.ul),
            isActive: _quillController.getSelectionStyle().attributes.containsKey('list'),
          ),
          const Spacer(),
          // Expand button
          _buildToolbarButton(
            icon: _isToolbarExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            onPressed: _toggleToolbar,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 20,
            color: isActive ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildExpandedToolbar() {
    final theme = Theme.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Formatting Tools',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _toggleToolbar,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ],
              ),
            ),
            // Full QuillSimpleToolbar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: quill.QuillSimpleToolbar(
                controller: _quillController,
                config: const quill.QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showDividers: true,
                  showFontFamily: false,
                  showFontSize: false,
                  showBoldButton: true,
                  showItalicButton: true,
                  showSmallButton: false,
                  showUnderLineButton: true,
                  showStrikeThrough: true,
                  showInlineCode: true,
                  showColorButton: true,
                  showBackgroundColorButton: true,
                  showClearFormat: true,
                  showAlignmentButtons: true,
                  showLeftAlignment: true,
                  showCenterAlignment: true,
                  showRightAlignment: true,
                  showJustifyAlignment: true,
                  showHeaderStyle: true,
                  showListNumbers: true,
                  showListBullets: true,
                  showListCheck: true,
                  showCodeBlock: true,
                  showIndent: true,
                  showLink: true,
                  showUndo: true,
                  showRedo: true,
                  showDirection: false,
                  showSearchButton: false,
                  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _titleController.dispose();
    _quillController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _shareNote,
            icon: Icon(Icons.share, color: theme.colorScheme.onSurface),
          )
        ],
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 16),
                // Toolbar section
                _isToolbarExpanded ? _buildExpandedToolbar() : _buildMinimalToolbar(),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: quill.QuillEditor.basic(
                        controller: _quillController,
                        config: const quill.QuillEditorConfig(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
