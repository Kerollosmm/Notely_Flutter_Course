import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;

  const SearchBarWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search notes',
        hintStyle: const TextStyle(color: Colors.grey),
        // Use prefixIcon to place the icon inside the text field
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        // Set the background color
        fillColor: Colors.grey.shade200,
        filled: true,
        // Define the border and make it seamless
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none, // No visible border
        ),
        // Adjust padding for better visual spacing
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
      ),
    );
  }
}