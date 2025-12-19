import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoteTitleField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;

  const NoteTitleField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText = 'Title',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
      ),
      maxLines: 1, // Keep title to a single line typically
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
