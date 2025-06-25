import 'package:flutter/material.dart' show immutable;

@immutable
abstract class AuthEvents {
  const AuthEvents();
}

class AuthEventsInitialize extends AuthEvents {
  const AuthEventsInitialize();
}

class AuthEventsLogIn extends AuthEvents {
  final String email;
  final String password;

 const AuthEventsLogIn(this.email, this.password);
}

class AuthEventsLogOut extends AuthEvents{
  const AuthEventsLogOut();
}


