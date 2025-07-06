import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search notes...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        // Removed borderRadius and boxShadow to make it a simple rectangle
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }
}
