import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/Auth_screens/forgot_password_view.dart';
import 'package:flutter_course_2/Auth_screens/loginpage.dart';
import 'package:flutter_course_2/Auth_screens/registerScreen.dart';
import 'package:flutter_course_2/Auth_screens/veryfy.dart';
import 'package:flutter_course_2/helpers/loading/loading_screen.dart';
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
    context.read<AuthBloc>().add(const AuthEventInitialize());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context, text: state.loadingText ?? 'please wait a moment ');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginScreen();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterScreen();
        } else {
          return const LaudingScreen();
        }
      },
    );
  }
}

class LaudingScreen extends StatelessWidget {
  const LaudingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: CircularProgressIndicator(
        color: Colors.blue,
      )),
    );
  }
}

