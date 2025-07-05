import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:flutter_course_2/firebase_options.dart';
import 'package:flutter_course_2/services/auth/auth_user.dart';
import 'package:flutter_course_2/services/auth/auth_exception.dart';
import 'package:flutter_course_2/services/auth/auth_provider.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      // Add retry logic for reCAPTCHA errors
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          final user = currentUser;
          if (user != null) {
            return user;
          } else {
            throw UserNotLoginAuthExceptions();
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            throw WeakPasswordAuthExceptions();
          } else if (e.code == 'email-already-in-use') {
            throw EmailAlreadyInUseAuthExceptions();
          } else if (e.code == 'invalid-email') {
            throw InvalidEmailAuthExceptions();
          } else if (e.code == 'network-request-failed' || 
                     e.message?.contains('network error') == true ||
                     e.message?.contains('unreachable host') == true) {
            retryCount++;
            if (retryCount >= maxRetries) {
              throw GenericAuthExceptions();
            }
            // Wait before retrying
            await Future.delayed(Duration(seconds: 2 * retryCount));
            continue;
          } else {
            throw GenericAuthExceptions();
          }
        }
      }
      throw GenericAuthExceptions();
    } catch (_) {
      throw GenericAuthExceptions();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      // Add retry logic for reCAPTCHA errors
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          final user = currentUser;
          if (user != null) {
            return user;
          } else {
            throw UserNotLoginAuthExceptions();
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            throw UserNotFoundAuthExceptions();
          } else if (e.code == 'wrong-password') {
            throw WrongPasswordAuthException();
          } else if (e.code == 'network-request-failed' || 
                     e.message?.contains('network error') == true ||
                     e.message?.contains('unreachable host') == true) {
            retryCount++;
            if (retryCount >= maxRetries) {
              throw GenericAuthExceptions();
            }
            // Wait before retrying
            await Future.delayed(Duration(seconds: 2 * retryCount));
            continue;
          } else {
            throw GenericAuthExceptions();
          }
        }
      }
      throw GenericAuthExceptions();
    } catch (_) {
      throw GenericAuthExceptions();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoginAuthExceptions();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoginAuthExceptions();
    }
  }

 @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthExceptions();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthExceptions();
        default:
          throw GenericAuthExceptions();
      }
    } catch (_) {
      throw GenericAuthExceptions();
    }
  }
}

