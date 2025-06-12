import 'package:flutter/material.dart';
import 'package:flutter_course_2/services/auth/auth_exception.dart';
import 'package:flutter_course_2/services/auth/auth_provider.dart';
import 'package:flutter_course_2/services/auth/auth_user.dart';

import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to  begin with ', () {
      expect(provider.IsInistialized, false);
    });

    test('cannot log out ', () {
      expect(provider.logOut(), () {
        throwsA(const TypeMatcher<NotInitializedExceptions>());
      });
    });
    test("should be able to be initializedf ", () async {
      await provider.initialize();
      expect(provider.IsInistialized, true);
    });
    test("user should be null", () {
      expect(provider.currentUser, null);
    });
    test(
      "should be able inisitalize in 2 secound ",
      () async {
        await provider.initialize();
        expect(provider.IsInistialized, true);
      },
    );
    test("create user should delegade  to logIn function", () async {
      final badEmail =
          provider.createUser(email: "foo@bar.com", password: 'anypassword');
      expect(
          badEmail, throwsA(const TypeMatcher<UserNotFoundAuthExceptions>()));
      final badPassword =
          provider.createUser(email: 'someone@bar.com', password: 'foobar');
      expect(badPassword,
          throwsA(const TypeMatcher<UserNotFoundAuthExceptions>()));

      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user!.isEmailVerified, false);
    });
    test('logged in user should be able to get verified ', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);

    });
    test ('should be able to log out', ()async{
      await provider.logOut();
      await provider.logIn(email: "user", password: 'password');
      final user = provider.currentUser;
      expect(user,isNotNull);
    });
  });
}

class NotInitializedExceptions implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialize = false;
  bool get IsInistialized => _isInitialize;
  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    if (!IsInistialized) throw NotInitializedExceptions();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialize = true;
  }

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) {
    if (!IsInistialized) throw NotInitializedExceptions();
    if (email == 'foo@bar.com') throw UserNotFoundAuthExceptions();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'foo@bar.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!IsInistialized) throw NotInitializedExceptions();
    if (_user == null) throw UserNotFoundAuthExceptions();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!IsInistialized) throw NotInitializedExceptions();
    final user = _user;
    if (user == null) throw UserNotFoundAuthExceptions();
    const newUser = AuthUser(isEmailVerified: true, email: 'foo@bar.com');
    _user = newUser;
  }
  
}
