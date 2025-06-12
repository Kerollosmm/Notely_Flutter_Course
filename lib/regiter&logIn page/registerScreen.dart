import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'dart:developer' as devtools show log;

import 'package:flutter_course_2/firebase_options.dart';
import 'package:flutter_course_2/page/home_padge.dart';
import 'package:flutter_course_2/page/veryfy.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/auth/auth_exception.dart';
import 'package:flutter_course_2/widgets/Botton.dart';
import 'package:flutter_course_2/widgets/ErrorDialog.dart';
import 'package:flutter_course_2/widgets/customFeild.dart';
import 'package:flutter_course_2/widgets/auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      title: "Create Account",
      subtitle: "Sign up to get started",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _email,
            hintText: "Email Address",
            keyboardType: TextInputType.emailAddress,
            isPassword: false,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          CustomTextField(
            controller: _password,
            hintText: 'Password',
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
          const SizedBox(height: 24),
          Bottom(
            title: "Register",
            isLoading: _isLoading,
            ontap: () async {
              setState(() {
                _isLoading = true;
              });

              final email = _email.text;
              final password = _password.text;

              try {
                await AuthSeries.firebase().createUser(
                  email: email,
                  password: password,
                );

                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  await AuthSeries.firebase().sendEmailVerification();
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
                  "Password",
                  "The password provided is too weak.",
                );
              } on EmailAlreadyInUseAuthExceptions {
                showErrorDialog(
                  context,
                  "Email",
                  "The email address is already in use.",
                );
              } on InvalidEmailAuthExceptions {
                showErrorDialog(context, "Email", "Invalid Email.");
              } on GenericAuthExceptions {
                showErrorDialog(
                  context,
                  "Error",
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
              const Text(
                "Already have an account?",
                style: TextStyle(color: Colors.white70),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Login Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E8D7C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white38)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("OR", style: TextStyle(color: Colors.white38)),
              ),
              Expanded(child: Divider(color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialButton(
                icon: 'assets/icons/google.png',
                onTap: () {
                  showErrorDialog(
                    context,
                    "Wait",
                    "This Fueter not availbel yet",
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
                    "This Fueter not availbel yet",
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialButton({required String icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Image.asset(icon),
      ),
    );
  }
}
