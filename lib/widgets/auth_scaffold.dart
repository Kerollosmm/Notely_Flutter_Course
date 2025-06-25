import 'package:flutter/material.dart';

class AuthScreenLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;

  const AuthScreenLayout({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      // Scaffold background color will be taken from AppTheme's scaffoldBackgroundColor
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), // Slightly less rounded
                color: theme.colorScheme.surface, // Use surface color from theme
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05), // Softer shadow
                    blurRadius: 20, // Increased blur
                    offset: const Offset(0, 8), // Adjusted offset
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      textAlign: TextAlign.center, // Center align title
                      style: textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center, // Center align subtitle
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}