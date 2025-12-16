import 'package:flutter/material.dart';
import 'package:flutter_course_2/enums/note_background_style.dart';
import 'package:flutter_course_2/widgets/note_background_painter.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoteEditorField extends StatelessWidget {
  final quill.QuillController controller;
  final FocusNode? focusNode;
  final NoteBackgroundStyle backgroundStyle;

  const NoteEditorField({
    super.key,
    required this.controller,
    this.focusNode,
    this.backgroundStyle = NoteBackgroundStyle.plain,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: CustomPaint(
        painter: NoteBackgroundPainter(
          style: backgroundStyle,
          lineColor: theme.dividerColor.withValues(alpha: 0.5), // Use theme color
          lineSpacing: 24.h, // Responsive line spacing
        ),
        child: Container(
          decoration: BoxDecoration(
            // Ensure cardColor is only applied if plain, or painter handles background
            color: backgroundStyle == NoteBackgroundStyle.plain ? theme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
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
