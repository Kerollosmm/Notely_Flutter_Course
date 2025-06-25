import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_course_2/Auth_screens/veryfy.dart';

import 'dart:developer' as devtools show log;

import 'package:flutter_course_2/firebase_options.dart';
import 'package:flutter_course_2/page/note_view.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/auth/auth_exception.dart';
import 'package:flutter_course_2/utailates/dialogs/error_dialog.dart';
import 'package:flutter_course_2/widgets/Botton.dart'; // Will be CustomButton
import 'package:flutter_course_2/widgets/customFeild.dart';
import 'package:flutter_course_2/widgets/auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      title: "Create Account",
      subtitle: "Sign up to get started",      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomTextField(
                controller: _email,
                labelText: "Email Address",
                hintText: "Enter your email",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomTextField(
                controller: _password,
                labelText: 'Password',
                hintText: 'Enter your password',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                    return 'Password must contain at least one letter';
                  }
                  if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Password must contain at least one number';
                  }
                  return null; // password is valid
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton( // Changed from Bottom to CustomButton
            title: "Register",
            isLoading: _isLoading,
            ontap: () async {
              setState(() {
                _isLoading = true;
              });

              final email = _email.text;
              final password = _password.text;

              try {
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );

                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  await AuthService.firebase().sendEmailVerification();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EmailVerificationDialog(Email: _email.text);
                    },
                  );
                }
              } on WeakPasswordAuthExceptions {
                showErrorDialog(
                  context,
                  "The password provided is too weak.",
                );
              } on EmailAlreadyInUseAuthExceptions {
                showErrorDialog(
                  context,
                  "The email address is already in use.",
                );
              } on InvalidEmailAuthExceptions {
                showErrorDialog(context, "Invalid Email.");
              } on GenericAuthExceptions {
                showErrorDialog(
                  context,
                  "An error occurred while registering. Please try again.",
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Login Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24), // Increased spacing
          Row(
            children: [
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("OR", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              ),
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            ],
          ),
          const SizedBox(height: 24), // Increased spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialButton(
                icon: 'assets/icons/google.png',
                onTap: () {
                  showErrorDialog(
                    context,
                    "Wait",
                  );
                },
              ),
              const SizedBox(width: 24),
              _socialButton(
                icon: 'assets/icons/facebook.png',
                onTap: () {
                  // Add Facebook auth logic
                  showErrorDialog(
                    context,
                    "Wait",
                  );
                },
              ),
            ],
          ),
        ],
      ),
    )
      )
    );
  }

  Widget _socialButton({required String icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56, // Increased size
        height: 56, // Increased size
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant, // Use surfaceVariant for background
          borderRadius: BorderRadius.circular(16), // More rounded corners
          border: Border.all(color: Theme.of(context).dividerColor) // Optional: add a subtle border
        ),
        padding: const EdgeInsets.all(14), // Adjusted padding
        child: Image.asset(icon),
      ),
    );
  }
}
