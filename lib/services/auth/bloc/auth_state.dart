import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:flutter_course_2/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'please wait a moment ',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
    : super(isLoading: isLoading);
}

class AuthStateLogIn extends AuthState {
  final AuthUser user;
  const AuthStateLogIn({required this.user, required bool isLoading})
    : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required bool isLoading})
    : super(isLoading: isLoading);
}

class AuthStateLogOut extends AuthState with EquatableMixin {
  final Exception? exception;
  AuthStateLogOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateRegister extends AuthState {
  final Exception exception;

  const AuthStateRegister({required this.exception, required isLoading})
    : super(isLoading: isLoading);
}
