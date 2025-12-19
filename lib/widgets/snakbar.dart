// Separate Widget for Warning SnackBar
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WarningSnackBar extends SnackBar {
  final String message;

  WarningSnackBar({super.key, required this.message})
    : super(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE6A10B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
        elevation: 4,
        duration: const Duration(seconds: 4),
      );
}

// Separate Widget for Neutral SnackBar
class NeutralSnackBar extends SnackBar {
  final String message;

  NeutralSnackBar({super.key, required this.message})
    : super(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4E8D7C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
        elevation: 4,
        duration: const Duration(seconds: 4),
      );
}

// Separate Widget for Error SnackBar
class ErrorSnackBar extends SnackBar {
  final String message;

  ErrorSnackBar({super.key, required this.message})
    : super(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
        elevation: 4,
        duration: const Duration(seconds: 4),
      );
}
