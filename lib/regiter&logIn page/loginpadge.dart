import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_course_2/page/home_padge.dart';
import 'package:flutter_course_2/page/veryfy.dart';
import 'package:flutter_course_2/regiter&logIn page/registerScreen.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/services/auth/auth_exception.dart';
import 'package:flutter_course_2/widgets/Botton.dart';
import 'package:flutter_course_2/widgets/ErrorDialog.dart';
import 'package:flutter_course_2/widgets/customFeild.dart';
import 'package:flutter_course_2/widgets/auth_scaffold.dart';
import 'package:flutter_course_2/widgets/snakbar.dart';

import 'dart:developer' as devtools show log;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenLayout(
      title: "Login",
      subtitle: "Sign in to your account",
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Forgot password logic
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xFF4E8D7C),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Bottom(
            title: "Login",
            isLoading: _isLoading,
            ontap: () async {
              setState(() {
                _isLoading = true;
              });
              
              devtools.log("Bottom clicked");
              final email = _email.text;
              final password = _password.text;
              
              if (email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  ErrorSnackBar(
                    message: "Please fill all fields to continue"
                  ),
                );
                setState(() {
                  _isLoading = false;
                });
              } else {
                try {
                  await AuthSeries.firebase().logIn(
                    email: email,
                    password: password
                  );

                  final user = AuthSeries.firebase().currentUser;
                  final userEmail = _email.text;

                  if (user?.isEmailVerified ?? false) {
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return EmailVerificationDialog(
                            Email: userEmail,
                          );
                        },
                      );
                    }
                  }
                } on UserNotFoundAuthExceptions {
                  showErrorDialog(
                    context,
                    "User Not Found",
                    "May be the password or Email are Wrong"
                  );
                  devtools.log('no user found');
                } on WrongPasswordAuthException {
                  showErrorDialog(
                    context,
                    "username and password",
                    "Please check your password and Email"
                  );
                  devtools.log('Wrong passWord');
                } on GenericAuthExceptions {
                  showErrorDialog(
                    context,
                    "Authentication error",
                    "An unexpected error occurred during authentication"
                  );
                  devtools.log('error:');
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Register Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E8D7C),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white38)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "OR",
                  style: TextStyle(color: Colors.white38),
                ),
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
