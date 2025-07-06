import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_course_2/utailates/dialogs/delete_dialog.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

typedef NoteCallback = void Function(CloudNote note);

class NoteListView extends StatelessWidget {
  final List<CloudNote> notes;
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
        final plainText = _getPlainText(note.text);

        return GestureDetector(
          onTap: () => onTap(note),
          onLongPress: () async {
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              onDeleteNote(note);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(Icons.article_outlined, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blue.shade800),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isEmpty ? "Untitled Note" : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plainText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
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
