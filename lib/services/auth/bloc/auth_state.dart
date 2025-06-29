import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:flutter_course_2/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateLogIn extends AuthState {
  final AuthUser user;
  const AuthStateLogIn(this.user);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLogOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;

  AuthStateLogOut({required this.exception, required this.isLoading});

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateRegister extends AuthState {
  final Exception exception;

  const AuthStateRegister(this.exception);
}
