import 'package:flutter/material.dart' show immutable;
import 'package:flutter_course_2/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLauding extends AuthState {
  const AuthStateLauding();
}

class AuthStateLogIn extends AuthState {
  final AuthUser user;
  const AuthStateLogIn(this.user);
}

class AuthStateLoginFailure extends AuthState {
  final Exception exception;
  const AuthStateLoginFailure(this.exception);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLogOut extends AuthState {
  const AuthStateLogOut();
}

class AuthStateLogOutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogOutFailure(this.exception);
}
