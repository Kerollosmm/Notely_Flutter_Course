import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/ios_theme.dart';

class Bottom extends StatelessWidget {
  final String title;
  final VoidCallback ontap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const Bottom({
    super.key,
    required this.title,
    required this.ontap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              // Add haptic feedback for iOS feel
              HapticFeedback.mediumImpact();
              ontap();
            },
      child: AnimatedContainer(
        duration: IOSTheme.shortAnimation,
        height: IOSTheme.buttonHeight,
        width: double.infinity,
        decoration: IOSTheme.buttonDecoration.copyWith(
          color: isLoading
              ? (backgroundColor ?? IOSTheme.primary).withOpacity(0.7)
              : backgroundColor ?? IOSTheme.primary,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                )
              : Text(
                  title,
                  style: IOSTheme.body.copyWith(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}