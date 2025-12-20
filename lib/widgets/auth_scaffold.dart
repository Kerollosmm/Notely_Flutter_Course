import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Container(
              padding: EdgeInsets.all(24.r),
              constraints: BoxConstraints(maxWidth: 400.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  16.r,
                ), // Slightly less rounded
                color:
                    theme.colorScheme.surface, // Use surface color from theme
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(
                      alpha: 0.05,
                    ), // Softer shadow
                    blurRadius: 20.r, // Increased blur
                    offset: Offset(0, 8.h), // Adjusted offset
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch to fill width
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      textAlign: TextAlign.center, // Center align title
                      style: textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center, // Center align subtitle
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
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
