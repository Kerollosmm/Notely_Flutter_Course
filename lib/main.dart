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
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          create: (context) =>
              AuthBloc(FirebaseAuthProvider())
                ..add(const AuthEventInitialize()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeNotifier(ThemeMode.system)),
      ],
      // ScreenUtilInit MUST wrap the entire app for responsive sizing
      child: ScreenUtilInit(
        // Design size based on Figma/XD (iPhone X default: 375x812)
        designSize: const Size(375, 812),
        // Adapts text size to screen density
        minTextAdapt: true,
        // Enables tablet/large screen support
        splitScreenMode: true,
        // The builder ensures ScreenUtil is initialized BEFORE MaterialApp builds
        builder: (context, child) => Consumer<ThemeNotifier>(
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
                Locale('ar'), // Arabic
              ],
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeNotifier.themeMode,
              // The home widget now has access to the AuthBloc.
              home: const AccountAnalyze(),
              // All named routes will also have access to the AuthBloc.
              routes: {
                createOrUpdateNoteRoute: (context) =>
                    const CreateUpdateNoteView(),
              },
            );
          },
        ),
      ),
    );
  }
}
