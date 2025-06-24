import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              HapticFeedback.mediumImpact();
              ontap();
            },
      child: Container(
        height: 48, // Default button height
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading
              ? (backgroundColor ?? Theme.of(context).primaryColor).withOpacity(0.7)
              : backgroundColor ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
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
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}