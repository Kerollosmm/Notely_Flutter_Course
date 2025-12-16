import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter_course_2/utailates/generics/get_arguments.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  _CreateUpdateNoteViewState createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final quill.QuillController _quillController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _quillController = quill.QuillController.basic();
    _titleController = TextEditingController();
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

  // Custom Google Keep style toolbar
  Widget _buildCustomToolbar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Formatting tools
            _buildToolbarButton(
              icon: Icons.format_bold,
              attribute: quill.Attribute.bold,
              tooltip: 'Bold',
            ),
            _buildToolbarButton(
              icon: Icons.format_italic,
              attribute: quill.Attribute.italic,
              tooltip: 'Italic',
            ),
            _buildToolbarButton(
              icon: Icons.format_underlined,
              attribute: quill.Attribute.underline,
              tooltip: 'Underline',
            ),
            _buildToolbarButton(
              icon: Icons.strikethrough_s,
              attribute: quill.Attribute.strikeThrough,
              tooltip: 'Strikethrough',
            ),
            _buildVerticalDivider(),
            // Text alignment
            _buildToolbarButton(
              icon: Icons.format_align_left,
              attribute: quill.Attribute.leftAlignment,
              tooltip: 'Align Left',
            ),
            _buildToolbarButton(
              icon: Icons.format_align_center,
              attribute: quill.Attribute.centerAlignment,
              tooltip: 'Align Center',
            ),
            _buildToolbarButton(
              icon: Icons.format_align_right,
              attribute: quill.Attribute.rightAlignment,
              tooltip: 'Align Right',
            ),
            _buildVerticalDivider(),
            // Lists and checkbox
            _buildToolbarButton(
              icon: Icons.format_list_bulleted,
              attribute: quill.Attribute.ul,
              tooltip: 'Bullet List',
            ),
            _buildToolbarButton(
              icon: Icons.format_list_numbered,
              attribute: quill.Attribute.ol,
              tooltip: 'Numbered List',
            ),
            _buildToolbarButton(
              icon: Icons.check_box_outline_blank,
              attribute: quill.Attribute.unchecked,
              tooltip: 'Checkbox',
            ),
            _buildVerticalDivider(),
            // Code and quote
            _buildToolbarButton(
              icon: Icons.format_quote,
              attribute: quill.Attribute.blockQuote,
              tooltip: 'Quote',
            ),
            _buildToolbarButton(
              icon: Icons.code,
              attribute: quill.Attribute.codeBlock,
              tooltip: 'Code Block',
            ),
            _buildVerticalDivider(),
            // Text size
            _buildToolbarButton(
              icon: Icons.format_size,
              attribute: quill.Attribute.h1,
              tooltip: 'Large Text',
            ),
            _buildToolbarButton(
              icon: Icons.text_fields,
              attribute: quill.Attribute.h2,
              tooltip: 'Medium Text',
            ),
            _buildVerticalDivider(),
            // Color picker
            _buildColorButton(),
            _buildBackgroundColorButton(),
            _buildVerticalDivider(),
            // Clear formatting
            _buildClearFormattingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required quill.Attribute attribute,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _quillController,
      builder: (context, child) {
        final attr = _quillController.getSelectionStyle().attributes[attribute.key];
        final isActive = attr?.value == attribute.value;
        
        return Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                _quillController.formatSelection(attribute);
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: isActive 
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                  border: isActive 
                    ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1)
                    : null,
                ),
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: isActive 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    final theme = Theme.of(context);
    return Container(
      width: 1.w,
      height: 24.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
    );
  }

  Widget _buildColorButton() {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: 'Text Color',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            _showColorPicker(isBackground: false);
          },
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Colors.transparent,
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.format_color_text,
                  size: 18.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                Positioned(
                  bottom: 8.h,
                  right: 8.w,
                  child: Container(
                    width: 12.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundColorButton() {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: 'Background Color',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            _showColorPicker(isBackground: true);
          },
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Colors.transparent,
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.format_color_fill,
                  size: 18.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                Positioned(
                  bottom: 8.h,
                  right: 8.w,
                  child: Container(
                    width: 12.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearFormattingButton() {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: 'Clear Formatting',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            final attrs = {
              quill.Attribute.bold,
              quill.Attribute.italic,
              quill.Attribute.underline,
              quill.Attribute.strikeThrough,
              quill.Attribute.h1,
              quill.Attribute.h2,
              quill.Attribute.h3,
              quill.Attribute.ul,
              quill.Attribute.ol,
              quill.Attribute.blockQuote,
              quill.Attribute.codeBlock,
              quill.Attribute.leftAlignment,
              quill.Attribute.centerAlignment,
              quill.Attribute.rightAlignment,
              quill.Attribute.justifyAlignment,
              quill.Attribute.color,
              quill.Attribute.background,
            };
            for (final attr in attrs) {
              _quillController.formatSelection(quill.Attribute.clone(attr, null));
            }
          },
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Colors.transparent,
            ),
            child: Icon(
              Icons.format_clear,
              size: 18.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker({required bool isBackground}) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            isBackground ? 'Background Color' : 'Text Color',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: SizedBox(
            width: 250.w,
            child: GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              mainAxisSpacing: 8.r,
              crossAxisSpacing: 8.r,
              children: [
                Colors.black, Colors.red, Colors.blue, Colors.green, Colors.yellow,
                Colors.orange, Colors.purple, Colors.pink, Colors.teal, Colors.indigo,
                Colors.grey, Colors.brown, Colors.cyan, Colors.lime, Colors.amber,
              ].map((color) => _buildColorOption(color, isBackground)).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () {
                // Remove color
                if (isBackground) {
                  _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.background, null));
                } else {
                  _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.color, null));
                }
                Navigator.of(context).pop();
              },
              child: Text('Remove', style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(Color color, bool isBackground) {
    return GestureDetector(
      onTap: () {
        final hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
        final attribute =
            isBackground ? quill.Attribute.background : quill.Attribute.color;
        _quillController.formatSelection(quill.Attribute.clone(attribute, hex));
        Navigator.of(context).pop();
      },
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
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
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface), // Fix deprecated onBackground
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: _shareNote,
            icon: Icon(Icons.share, color: theme.colorScheme.onSurface), // Fix deprecated onBackground
          )
        ],
      ),
      body: FutureBuilder<CloudNote>(
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
                style: TextStyle(color: theme.colorScheme.onSurface), // Fix deprecated onBackground
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface, // Fix deprecated onBackground
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5), // Fix deprecated onBackground
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                ),
                SizedBox(height: 16.h),
                // Custom Google Keep style toolbar
                Center(child: _buildCustomToolbar()),
                SizedBox(height: 16.h),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                      config: const quill.QuillEditorConfig(
                        placeholder: 'Start writing...',
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
