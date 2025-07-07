import 'package:flutter/material.dart';
import 'package:flutter_course_2/enums/note_background_style.dart';
import 'package:flutter_course_2/widgets/note_background_painter.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class NoteEditorField extends StatelessWidget {
  final quill.QuillController controller;
  final FocusNode? focusNode;
  final NoteBackgroundStyle backgroundStyle;

  const NoteEditorField({
    Key? key,
    required this.controller,
    this.focusNode,
    this.backgroundStyle = NoteBackgroundStyle.plain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: CustomPaint(
        painter: NoteBackgroundPainter(
          style: backgroundStyle,
          lineColor: theme.dividerColor.withOpacity(0.5), // Use theme color
        ),
        child: Container(
          decoration: BoxDecoration(
            // Ensure cardColor is only applied if plain, or painter handles background
            color: backgroundStyle == NoteBackgroundStyle.plain ? theme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: quill.QuillEditor.basic(
              controller: controller,
              config: const quill.QuillEditorConfig(
                 expands: true, // Important for CustomPaint to get correct size
              ),
            ),
          ),
        ),
      ),
    );
  }
}
