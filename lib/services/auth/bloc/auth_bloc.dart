// lib/services/auth/bloc/auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:flutter_course_2/services/auth/auth_provider.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvents, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    //send email verification
    on<AuthEventsSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    on<AuthEventsRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegister(e));
      }
    });
    //Initialize
    on<AuthEventsInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(AuthStateLogOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLogIn(user));
      }
    });
    //log in
    on<AuthEventsLogIn>((event, emit) async {
      emit(AuthStateLogOut(exception: null, isLoading: true));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);

        // Add a null check here
        if (user == null) {
          emit(AuthStateLogOut(
              exception: Exception('User not found'), isLoading: false));
          return;
        }

        if (!user.isEmailVerified) {
          emit(AuthStateLogOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLogOut(exception: null, isLoading: false));
          emit(AuthStateLogIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLogOut(exception: e, isLoading: false));
      }
    });
    //logOut
    on<AuthEventsLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(AuthStateLogOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLogOut(exception: e, isLoading: false));
      }
    });
  }
}