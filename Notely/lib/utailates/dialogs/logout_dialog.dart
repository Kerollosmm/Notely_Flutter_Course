import 'package:flutter/material.dart';
import 'package:flutter_course_2/utailates/dialogs/genric_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Confirm Logout',
    content: 'Are you sure you want to logout?',
    optionBuilder: () => {'Cancel': false, 'Logout': true},
  ).then((value) => value ?? false);
}
