import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/Auth_screens/loginpage.dart';
import 'package:flutter_course_2/Auth_screens/registerScreen.dart';
import 'package:flutter_course_2/Auth_screens/veryfy.dart';
import 'package:flutter_course_2/constants/app_theme.dart';
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
    context.read<AuthBloc>().add(const AuthEventsInitialize());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc , AuthState>(
      listener: (context , state){
        if (state.isLoading){
          // TODO: show loading indicator
          LoadingScreen().show(context: context, text:state.loadingText ?? 'please wait a moment ');
        }else{
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLogIn) {
          return NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return Scaffold(body: Center(child: EmailVerificationDialog()));
        } else if (state is AuthStateLogOut) {
          return const LoginScreen();
        }else if(state is AuthStateRegister){
          return const RegisterScreen();

        }else{
          return LaudingScreen();
        }
      },
    );
  }
}

class LaudingScreen extends StatelessWidget {
  const LaudingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:CircularProgressIndicator(
          color: AppTheme.secondaryColorLight,
        )
      ),
    );
  }
}
