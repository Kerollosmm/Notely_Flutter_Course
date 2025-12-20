import 'package:flutter/material.dart';
import 'package:flutter_course_2/utailates/dialogs/genric_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Confirm Delete',
    content: 'Are you sure you want to delete this note?',
    optionBuilder: () => {'Cancel': false, 'Delete': true},
  ).then((value) => value ?? false);
}
