import 'package:flutter/material.dart';

Future<String?> showAddSectionDialog(
  BuildContext context,
  List<String> existingSections,
) {
  final textController = TextEditingController();
  return showDialog<String?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Section'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Enter new section name',
              ),
            ),
            const SizedBox(height: 16),
            if (existingSections.isNotEmpty) ...[
              const Text('Or select an existing one:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: existingSections
                    .map(
                      (section) => ActionChip(
                        label: Text(section),
                        onPressed: () {
                          Navigator.of(context).pop(section);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newSection = textController.text.trim();
              if (newSection.isNotEmpty) {
                Navigator.of(context).pop(newSection);
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
