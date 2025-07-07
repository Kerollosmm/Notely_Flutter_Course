import 'package:flutter/material.dart';
import 'package:flutter_course_2/enums/note_background_style.dart';

class NoteBackgroundPainter extends CustomPainter {
  final NoteBackgroundStyle style;
  final Color lineColor;
  final double lineSpacing;

  NoteBackgroundPainter({
    required this.style,
    this.lineColor = Colors.black12, // Default subtle line color
    this.lineSpacing = 24.0, // Typical line height
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (style == NoteBackgroundStyle.plain) {
      return; // Nothing to paint for plain style
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5; // Thin lines

    if (style == NoteBackgroundStyle.ruledLines) {
      for (double y = lineSpacing; y < size.height; y += lineSpacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else if (style == NoteBackgroundStyle.gridLines) {
      // Horizontal lines
      for (double y = lineSpacing; y < size.height; y += lineSpacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
      // Vertical lines
      for (double x = lineSpacing; x < size.width; x += lineSpacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant NoteBackgroundPainter oldDelegate) {
    return oldDelegate.style != style ||
           oldDelegate.lineColor != lineColor ||
           oldDelegate.lineSpacing != lineSpacing;
  }
}
