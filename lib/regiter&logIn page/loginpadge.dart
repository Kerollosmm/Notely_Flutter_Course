import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_course/page/home_padge.dart';
import 'package:flutter_course/page/veryfy.dart';
import 'package:flutter_course/regiter&logIn%20page/registerScreen.dart';
import 'package:flutter_course/services/auth/Auth_servies.dart';
import 'package:flutter_course/services/auth/auth_exception.dart';
import 'package:flutter_course/widgets/Botton.dart';
import 'package:flutter_course/widgets/ErrorDialog.dart';

import 'dart:developer' as devtools show log;

import 'package:flutter_course/widgets/customFeild.dart';
import 'package:flutter_course/widgets/snakbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _name = TextEditingController();

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
                                "Login",
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
                                          devtools.log("Bottom clicked");
                                          final email = _email.text;
                                          final password = _password.text;
                                          final name = _name.text;
                                          if (email.isEmpty ||
                                              password.isEmpty ||
                                              name.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              ErrorSnackBar(
                                                  message:
                                                      "Please man fill all information you don't lose your hand man"),
                                            );
                                          } else {
                                            try {
                                              await AuthSeries.firebase()
                                                  .logIn(
                                                      email: email,
                                                      password: password);

                                              final User =
                                                  AuthSeries.firebase()
                                                      .currentUser;
                                              final Email= _email.text;

                                              if (User?.isEmailVerified ??
                                                  false) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeScreen(),
                                                  ),
                                                );
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return EmailVerificationDialog(
                                                      Email:Email,
                                                    );
                                                  },
                                                );
                                              }
                                            } on UserNotFoundAuthExceptions {
                                              showErrorDialog(
                                                  context,
                                                  "User Not Found",
                                                  "May be the password or Email are Wrong");
                                              devtools.log('no user found');
                                            } on WrongPasswordAuthException {
                                              showErrorDialog(
                                                  context,
                                                  "username and password",
                                                  "Please check your password and Email");
                                              devtools.log('Wrong passWord');
                                            } on GenericAuthExceptions {
                                              showErrorDialog(
                                                  context,
                                                  "Authentication error",
                                                  "An unexpected error occurred during authentication");
                                              devtools.log('error:');
                                            }
                                          }
                                        }),
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "not have account? Register Now !",
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
