import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAlert extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;
  final String buttonText1;
  final String buttonText2;

  const MyAlert({
    super.key,
    required this.text1,
    required this.text2,
    required this.onConfirm,
    required this.onDismiss,
    required this.buttonText1,
    required this.buttonText2,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      content: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text1,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              text2,
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 25.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: onDismiss, // Invoke the callback directly
                  child: Text(
                    buttonText2,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
