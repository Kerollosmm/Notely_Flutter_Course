import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();
  return showDialog<T?>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            content,
            style: TextStyle(fontSize: 15),
          ),
        ),
        actions: options.keys.map((optionTitle) {
          final T value = options[optionTitle];
          return CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              optionTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: CupertinoColors.activeBlue,
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}
