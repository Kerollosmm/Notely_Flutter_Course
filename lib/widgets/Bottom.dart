import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback ontap;
  final Color? backgroundColor; // Can still be used for specific overrides
  final Color? textColor; // Can still be used for specific overrides
  final double? width;
  final double? height;
  final Widget? icon; // Optional icon for the button

  const CustomButton({
    super.key,
    required this.title,
    required this.ontap,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Define the base style from the image design.
    // This creates the blue, pill-shaped button look by default.
    final ButtonStyle baseStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1976D2), // A nice, solid blue color
      foregroundColor: Colors.white, // White text for good contrast
      shape: const StadiumBorder(), // This creates the fully rounded "pill" shape
      elevation: 0, // No shadow, for a flatter look like in the image
      textStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
    );

    // Get the button style from the application's theme.
    // This allows for global overrides.
    final ButtonStyle? themeStyle = Theme.of(context).elevatedButtonTheme.style;

    // Define overrides from the widget's constructor parameters.
    // This allows for specific overrides on a per-button basis.
    final ButtonStyle overrideStyle = ButtonStyle(
      backgroundColor: backgroundColor != null ? WidgetStateProperty.all(backgroundColor) : null,
      foregroundColor: textColor != null ? WidgetStateProperty.all(textColor) : null,
      fixedSize: (width != null || height != null)
          ? WidgetStateProperty.all(Size(width ?? double.infinity, height ?? 48.h))
          : null,
    );

    // Layer the styles correctly:
    // 1. Start with the base style.
    // 2. Merge the theme style over it (theme wins over base).
    // 3. Merge the override style over that (constructor params win over all).
    final ButtonStyle finalStyle = baseStyle.merge(themeStyle).merge(overrideStyle);

    return SizedBox(
      width: width ?? double.infinity, // Use provided width or expand to fill
      height: height ?? 48.h, // Use provided height or default to 48
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          ontap();
        },
        style: finalStyle,
        child: (icon != null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  SizedBox(width: 8.w), // Space between icon and text
                  Text(title),
                ],
              )
            : Text(title),
      ),
    );
  }
}