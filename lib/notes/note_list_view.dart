import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';
import 'package:flutter_course_2/utailates/dialogs/delete_dialog.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class NoteListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NoteListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  String _getPlainText(String jsonText) {
    if (jsonText.isEmpty) return "No content";
    try {
      // Decode the JSON string into a list of maps
      final delta = jsonDecode(jsonText);
      // Create a Quill Document from the Delta
      final doc = quill.Document.fromJson(delta);
      // Convert the document to plain text, trim it, and replace newlines
      return doc.toPlainText().trim().replaceAll(RegExp(r'\s+'), ' ');
    } catch (e) {
      // If decoding fails, it's likely plain text already
      return jsonText.trim().replaceAll(RegExp(r'\s+'), ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final plainText = _getPlainText(note.contentJson);
        // DatabaseNote doesn't have a title field, so we use the first few words of content or "Untitled"
        final title = plainText.isNotEmpty
            ? (plainText.length > 20
                  ? '${plainText.substring(0, 20)}...'
                  : plainText)
            : "Untitled Note";

        return GestureDetector(
          onTap: () => onTap(note),
          onLongPress: () async {
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              onDeleteNote(note);
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.blue.shade800,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        plainText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
