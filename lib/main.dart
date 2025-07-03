import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/Auth_screens/accounAnalyz.dart';
import 'package:flutter_course_2/constants/app_theme.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/page/create_update_note_view.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/firebase_auth_provider.dart';

// New widget for AI introduction
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI App Introduction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to our AI-powered app!'),
            const SizedBox(height: 20),
            const Text('Experience intelligence in action.'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AccountAnalyze())),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
void main() async {
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
      theme: AppTheme.lightTheme, //C:\Users\KimoStore\flutter_course\flutter_course_2\test.json
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const AccountAnalyze(),
      ),
    );
  }
}
