import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_course/firebase_options.dart';
import 'package:flutter_course/services/auth/auth_user.dart';
import 'package:flutter_course/services/auth/auth_provider.dart';
import 'package:flutter_course/services/auth/auth_exception.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return null;
      } else {
        throw UserNotLoginAuthExceptions();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthExceptions();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthExceptions();
      } else if (e.code == "invalid-email") {
        throw InvalidEmailAuthExceptions();
      } else {
        throw GenericAuthExceptions();
      }
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
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        return null;
      } else {
        throw UserNotLoginAuthExceptions();
      }
    } on FirebaseAuthException catch (e) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthExceptions();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException ();  
      } else {
        throw GenericAuthExceptions();
      }
    } catch (_) {
      throw GenericAuthExceptions();
    }
  }

  @override
  Future<void> logOut()async {
   final user = currentUser;
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
  Future<void> initialize()async{
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
        );
   
  }
}
