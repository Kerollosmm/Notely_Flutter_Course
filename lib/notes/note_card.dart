import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/cloud/cloud_note.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteCard extends StatelessWidget {
  final CloudNote note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String plainText;
    try {
      final delta = jsonDecode(note.text);
      final doc = Document.fromJson(delta);
      plainText = doc.toPlainText();
    } catch (e) {
      plainText = note.text;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plainText,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}