import 'package:flutter/material.dart';
import 'package:flutter_course_2/utailates/dialogs/genric_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'reset Password',
    content: 'we send link to your email ',
    optionBuilder: ()=>{
      'Ok' : null
    }
  );
}