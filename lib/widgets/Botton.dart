import 'package:flutter/material.dart';

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
      onTap: isLoading ? null : ontap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF4E8D7C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (backgroundColor ?? const Color(0xFF4E8D7C)).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}