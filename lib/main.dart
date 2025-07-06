import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_course_2/Auth_screens/accounAnalyz.dart';
import 'package:flutter_course_2/constants/app_theme.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/page/create_update_note_view.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_course_2/services/auth/bloc/auth_events.dart';
import 'package:flutter_course_2/services/auth/firebase_auth_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:flutter_course_2/providers/theme_notifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// This import was causing an error because the package wasn't installed. We'll remove it for now and handle dependencies properly.


void main() async {
  // Ensure that the Flutter bindings are initialized before calling Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the AuthBloc to the entire application.
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider())..add(const AuthEventInitialize()),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(ThemeMode.system),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ar'), // Add this line for Arabic
            ],
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
            // The home widget now has access to the AuthBloc.
            home: const AccountAnalyze(),
            // All named routes will also have access to the AuthBloc.
            routes: {
              createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
            },
          );
        },
      ),
    );
  }
}