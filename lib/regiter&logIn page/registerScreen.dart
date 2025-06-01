import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_course/firebase_options.dart';
import 'package:flutter_course/page/home_padge.dart';
import 'package:flutter_course/page/veryfy.dart';

import 'package:flutter_course/services/auth/Auth_servies.dart';
import 'package:flutter_course/services/auth/auth_exception.dart';
import 'package:flutter_course/services/auth/auth_user.dart';
import 'package:flutter_course/widgets/Botton.dart';
import 'package:flutter_course/widgets/ErrorDialog.dart';

import 'dart:developer' as devtools show log;

import 'package:flutter_course/widgets/customFeild.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<RegisterScreen> {
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _name;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _name = TextEditingController();
    _initializeFirebase();
  }

  Future _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    setState(() {
      _isInitialized == true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backGround.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 150),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(
                          0.5), // adjust opacity to see the blur effect
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Register Now!",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              CustomTextField(
                                controller: _name,
                                hintText: "Entre your Name",
                                keyboardType: TextInputType.name,
                                isPassword: false,
                                prefixIcon: Icon(Icons.person),
                              ),
                              CustomTextField(
                                controller: _email,
                                hintText: "Email",
                                keyboardType: TextInputType.emailAddress,
                                isPassword: false,
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              CustomTextField(
                                controller:
                                    _password, // your password controller
                                hintText: 'Enter Password',
                                isPassword:
                                    true, // this will enable password mode

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
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 190,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      print("the botton is taped ");
                                    },
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Bottom(
  title: "Login",
  ontap: () async {
    final email = _email.text;
    final password = _password.text;
    final name = _name.text;

    try {
      // Create a new user
      await AuthSeries.firebase().createUser(email: email, password: password);

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the user exists and if the email is verified
      if (user != null) {
        if (user.emailVerified) {
          // Email is verified, navigate to the home page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  HomeScreen()),
          );
        } else {
          // Email not verified, prompt the user
          await AuthSeries.firebase().sendEmailVerification();
          // Show the email verification dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return EmailVerificationDialog(
                Email: _email.text,
              );
            },
          );
        }
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
      showErrorDialog(
        context,
        "Email",
        "Invalid  Email.",
      );
    } on GenericAuthExceptions {
      showErrorDialog(
        context,
        "Error",
        "An error occurred while registering. Please try again.",
      );
    }
  },
),

                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "aready have account !",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        )),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
