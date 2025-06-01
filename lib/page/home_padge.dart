import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/regiter&logIn%20page/loginpadge.dart';
// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: TextButton(onPressed: ()async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
            }, child: const Text("Log Out"))));
  }
}
