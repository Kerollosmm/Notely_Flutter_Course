import 'package:flutter_course_2/services/auth/auth_provider.dart';
import 'package:flutter_course_2/services/auth/auth_user.dart';
import 'package:flutter_course_2/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService({required this.provider});

  factory AuthService.firebase() => AuthService(
        provider: FirebaseAuthProvider(),
      );
  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) => 
      provider.logIn(
        email: email,
        password: password,
      );
  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  
  @override
  Future<void> initialize()=>provider.initialize();
  
  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => provider.currentUser;

    @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}

