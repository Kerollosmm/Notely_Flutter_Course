import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/Auth_screens/loginpadge.dart';
import 'package:flutter_course_2/Auth_screens/veryfy.dart';
import 'package:flutter_course_2/page/note_view.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_state.dart';

class AccountAnalyze extends StatefulWidget {
  const AccountAnalyze({Key? key}) : super(key: key);

  @override
  _AccountAnalyzeState createState() => _AccountAnalyzeState();
}

class _AccountAnalyzeState extends State<AccountAnalyze> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthEventsInitialize());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc , AuthState>(
      builder: (context, state) {
        if (state is AuthStateLogIn) {
          return NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return Scaffold(body: Center(child: EmailVerificationDialog()));
        } else if (state is AuthStateLogOut) {
          return const LoginScreen();
        }else{
          return SplashScreen();
        }
      },
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
                image: DecorationImage(image: AssetImage("assets/Applogo.jpg")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
