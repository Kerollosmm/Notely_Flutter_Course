import 'package:bloc/bloc.dart';
import 'package:flutter_course_2/services/auth/auth_provider.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvents, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLauding()) {
    //Initialize
    on<AuthEventsInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(AuthStateLogOut());
      } else if (!user.isEmailVerified) {
        emit(AuthStateNeedsVerification());
      } else {
        emit(AuthStateLogIn(user));
      }
    });
    //log in
    on<AuthEventsLogIn>((event, emit) async {
      emit(const AuthStateLauding());
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        emit(AuthStateLogIn(user!));
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });
    //logOut
    on<AuthEventsLogOut>((event, emit) async {
      try {
        emit(const AuthStateLauding());
        await provider.logOut();
        emit(const AuthStateLogOut());
      } on Exception catch (e) {
        emit(AuthStateLogOutFailure(e));
      }
    });
  }
}
