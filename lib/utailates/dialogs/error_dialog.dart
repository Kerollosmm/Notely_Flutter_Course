import 'package:flutter/material.dart';
import 'package:flutter_course_2/utailates/dialogs/genric_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
    context: context,
    title: 'An Error Occurred',
    content: text,
    optionBuilder: () => {'OK': null},
  );
}
