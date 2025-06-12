import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/page/home_padge.dart';
import 'package:flutter_course_2/regiter&logIn%20page/accounAnalyz.dart';
import 'package:flutter_course_2/regiter&logIn%20page/loginpadge.dart';
import 'package:flutter_course_2/regiter&logIn%20page/registerScreen.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the  root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
         loginRoute: (context) => const LoginScreen(),
        registerRoute: (context) => const RegisterScreen(),
        accountAnalyzeRoute: (context) => const AccountAnalyze(),
        HomePageRoute: (context) =>  HomeScreen(),      
      },
      home: const AccountAnalyze(),
    );
  }
}
