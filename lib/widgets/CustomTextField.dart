import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final String? labelText; // Added labelText

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.onTap,
    this.labelText, // Added labelText
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Using Theme.of(context) to access InputDecorationTheme defined in AppTheme
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduced margin, changed to padding
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        onTap: widget.onTap,
        style: textTheme.bodyLarge, // Use theme's bodyLarge style for input text
        decoration: InputDecoration(
          labelText: widget.labelText, // Use labelText
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon != null
              ? IconTheme(
                  data: IconTheme.of(context).copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  child: widget.prefixIcon!,
                )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          // The following properties are now primarily controlled by inputDecorationTheme in AppTheme:
          // contentPadding, hintStyle, filled, fillColor, border, enabledBorder, focusedBorder, errorBorder, focusedErrorBorder
          // However, you can override specific properties if needed for this particular widget.
        ),
      ),
    );
  }
}
