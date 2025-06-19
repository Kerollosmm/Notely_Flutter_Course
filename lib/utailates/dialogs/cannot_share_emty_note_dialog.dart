import 'package:flutter/material.dart';
import 'package:flutter_course_2/utailates/dialogs/genric_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing",
    content: "You Cannot share an Empty Note!",
    optionBuilder: () => {'ok': null},
  );
}
