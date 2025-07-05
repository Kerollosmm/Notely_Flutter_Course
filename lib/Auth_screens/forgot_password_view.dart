import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_state.dart';
import 'package:flutter_course_2/utailates/dialogs/error_dialog.dart';
import 'package:flutter_course_2/utailates/dialogs/show_reset_password_dialog.dart';
import 'package:flutter_course_2/widgets/CustomTextField.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            // Show a confirmation dialog when the email has been sent.
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            // Show an error dialog if there was an exception.
            await showErrorDialog(context,
                'We could not process your request. Please make sure you are a registered user.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          // Use a BlocBuilder to show a loading indicator while the request is in progress.
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'If you forgot your password, simply enter your email and we will send you a password reset link.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    CustomTextField(
                      controller: _controller,
                      hintText: 'Your email address',
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        final email = _controller.text;
                        // Dispatch the forgot password event.
                        context
                            .read<AuthBloc>()
                            .add(AuthEventForgotPassword(email: email));
                      },
                      child: const Text('Send me password reset link'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Dispatch the logout event to return to the login screen.
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      },
                      child: const Text('Back to Login Page'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
