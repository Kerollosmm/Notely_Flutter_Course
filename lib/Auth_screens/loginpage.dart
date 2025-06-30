import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_course_2/Auth_screens/registerScreen.dart';
import 'package:flutter_course_2/services/auth/auth_exception.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_state.dart';
import 'package:flutter_course_2/utailates/dialogs/error_dialog.dart';
import 'package:flutter_course_2/utailates/dialogs/loading_dialog.dart';
import 'package:flutter_course_2/widgets/Bottom.dart';
import 'package:flutter_course_2/widgets/CustomTextField.dart';
import 'package:flutter_course_2/widgets/auth_scaffold.dart';
import 'package:flutter_course_2/widgets/snakbar.dart';

import 'dart:developer' as devtools show log;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLogOut) {
          if (state.exception is UserNotFoundAuthExceptions) {
            await showErrorDialog(context, "User Not Found");
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, "Wrong Credentials");
          } else if (state.exception is GenericAuthExceptions) {
            await showErrorDialog(context, "Authentications Error ");
          }
        }
      },
      child: AuthScreenLayout(
        title: "Login",
        subtitle: "Sign in to your account",
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomTextField(
                      controller: _email,
                      labelText: "Email Address",
                      hintText: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                ),
                // const SizedBox(height: 16), // Spacing is handled by CustomTextField's padding
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password logic
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Increased spacing before button
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) async {},
                  child: CustomButton(
                    // Changed from Bottom to CustomButton
                    title: "Login",
                    ontap: () async {
                      final email = _email.text;
                      final password = _password.text;

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          ErrorSnackBar(
                            message: "Please fill all fields to continue",
                          ),
                        );
                      } else {
                        context.read<AuthBloc>().add(
                          AuthEventsLogIn(email, password),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          const AuthEventsShouldRegister(),
                        );
                      },
                      child: Text(
                        "Register Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Increased spacing
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Theme.of(context).dividerColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "OR",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Theme.of(context).dividerColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Increased spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(
                      icon: 'assets/icons/google.png',
                      onTap: () {
                        // Add Google auth logic
                      },
                    ),
                    const SizedBox(width: 24),
                    _socialButton(
                      icon: 'assets/icons/facebook.png',
                      onTap: () {
                        // Add Facebook auth logic
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
          color: Theme.of(
            context,
          ).colorScheme.surfaceVariant, // Use surfaceVariant for background
          borderRadius: BorderRadius.circular(16), // More rounded corners
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ), // Optional: add a subtle border
        ),
        padding: const EdgeInsets.all(14), // Adjusted padding
        child: Image.asset(icon),
      ),
    );
  }
}
