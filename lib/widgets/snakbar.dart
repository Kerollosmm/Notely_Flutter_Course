
// Separate Widget for Warning SnackBar
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WarningSnackBar extends SnackBar {
  final String message;
  WarningSnackBar({required this.message})
      : super(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 10),
              Text(message),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        );
}

// Separate Widget for Neutral SnackBar
class NeutralSnackBar extends SnackBar {
  final String message;
  NeutralSnackBar({required this.message})
      : super(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(message),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        );
}

// Separate Widget for Error SnackBar
class ErrorSnackBar extends SnackBar {
  final String message;
  ErrorSnackBar({required this.message})
      : super(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        );
}