import 'package:bloc/bloc.dart';
import 'package:flutter_course_2/services/auth/auth_provider.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_state.dart';
import 'package:flutter_course_2/services/crud/note_services.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // We need to initialize NoteRepository/Service upon login to ensure user exists in local DB
  final NotesService _notesService = NotesService();

  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });
    //forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return; // user just wants to go to forgot-password screen
      }

      // user wants to actually send a forgot-password email
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));
    });
    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      try {
        await provider.sendEmailVerification();
        emit(state);
      } on Exception catch (e) {
        // If we fail to send verification, we might want to log it or show a temporary error.
        // For now, staying on the same state but perhaps logging could be done.
        // Since AuthStateNeedsVerification doesn't hold exception, we can't easily show it
        // without changing the state definition.
        // However, crashing is worse.
        // Ideally we should emit a state that shows the error.
        emit(state);
      }
    });
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        // User is created and signed in (by firebase_auth default behavior).
        // Checks if user is not null is done inside provider.createUser

        await provider.sendEmailVerification();

        // We emit AuthStateNeedsVerification with justRegistered: true to signal the UI to show a SnackBar
        emit(const AuthStateNeedsVerification(
          isLoading: false,
          justRegistered: true,
        ));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });
    // initialize
    on<AuthEventInitialize>((event, emit) async {
      try {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          // Ensure local DB user exists
          try {
            await _notesService.getOrCreateUser(email: user.email);
          } catch (e) {
            // Log or ignore? If DB fails, we might have issues.
          }

          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while I log you in',
        ),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );

        if (user!.isEmailVerified) {
          // Ensure local DB user exists
          try {
              await _notesService.getOrCreateUser(email: user.email);
          } catch (e) {
             //
          }

          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        } else {
          emit(const AuthStateNeedsVerification(isLoading: false));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
    // log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });
  }
}
