import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback ontap;
  final bool isLoading;
  final Color? backgroundColor; // Can still be used for specific overrides
  final Color? textColor; // Can still be used for specific overrides
  final double? width;
  final double? height;
  final Widget? icon; // Optional icon for the button

  const CustomButton({
    super.key,
    required this.title,
    required this.ontap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Accessing the ElevatedButtonThemeData from the current theme
    final ElevatedButtonThemeData buttonTheme = Theme.of(context).elevatedButtonTheme;
    // Accessing the text style for buttons from the theme
    final TextStyle? buttonTextStyle = buttonTheme.style?.textStyle?.resolve({MaterialState.selected});


    return SizedBox(
      width: width ?? double.infinity, // Use provided width or expand
      height: height ?? 48, // Use provided height or default to 48
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.mediumImpact();
                ontap();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? (backgroundColor ?? buttonTheme.style?.backgroundColor?.resolve({MaterialState.disabled}))?.withOpacity(0.7)
              : backgroundColor ?? buttonTheme.style?.backgroundColor?.resolve({}),
          foregroundColor: textColor ?? buttonTheme.style?.foregroundColor?.resolve({}),
          textStyle: buttonTextStyle, // Apply the theme's button text style
          padding: buttonTheme.style?.padding?.resolve({}),
          shape: buttonTheme.style?.shape?.resolve({}),
          elevation: buttonTheme.style?.elevation?.resolve({}),
        ).copyWith(
           side: buttonTheme.style?.side, // Ensure side property is copied if defined in theme
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  // Use onPrimary color for the loader for better contrast on primary colored buttons
                  color: textColor ?? Theme.of(context).colorScheme.onPrimary,
                  strokeWidth: 2.0,
                ),
              )
            : (icon != null)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon!,
                    const SizedBox(width: 8), // Space between icon and text
                    Text(title),
                  ],
                )
              : Text(title),
      ),
    );
  }
}