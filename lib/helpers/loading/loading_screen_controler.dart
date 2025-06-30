import 'package:flutter/material.dart' show immutable;

typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String Text);

@immutable
class LoadingScreenController{
  final CloseLoadingScreen close;
  final UpdateLoadingScreen update;

 const LoadingScreenController(this.close, this.update);
}
