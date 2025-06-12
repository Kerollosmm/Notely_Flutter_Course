import 'package:flutter/material.dart';
import 'package:flutter_course_2/page/home_padge.dart';
import 'package:flutter_course_2/page/veryfy.dart';

import 'package:flutter_course_2/regiter&logIn page/loginpadge.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';

class AccountAnalyze extends StatefulWidget {
  const AccountAnalyze({Key? key}) : super(key: key);

  @override
  _AccountAnalyzeState createState() => _AccountAnalyzeState();
}

class _AccountAnalyzeState extends State<AccountAnalyze> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AuthSeries.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthSeries.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return  HomeScreen();
                } else {
                  return Scaffold(
                    body: Center(
                      child: EmailVerificationDialog(),
                    ),
                  );
                }
              } else {
                return const LoginScreen();
              }
            case ConnectionState.waiting:
              return const SplashScreen();
            default:
              return Center(child: Text('Error: ${snapshot.error}'));
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Applogo.jpg"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}