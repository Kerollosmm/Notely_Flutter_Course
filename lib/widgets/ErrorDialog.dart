import 'package:flutter/material.dart';

class Errorlog extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback onConfirm;
  final String buttonText1;

  const Errorlog({
    super.key,
    required this.text1,
    required this.text2,
    required this.onConfirm,
    required this.buttonText1,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              text2,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    onPressed: onConfirm, // Invoke the callback directly
                    child: Text(
                      buttonText1,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
Future<void> showErrorDialog(
  BuildContext context,
  String title,
  String message,
) {
  return showDialog(
      context: context,
      builder: (context) {
        return Errorlog(
          text1: title,
          text2: message,
          onConfirm: () {
            Navigator.of(context).pop();
          },
          buttonText1: 'ok',
        );
      });
}
