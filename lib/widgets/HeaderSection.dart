import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/enums.dart';

import 'dart:developer' as devTools show log;

import 'package:flutter_course_2/firebase_options.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';
import 'package:flutter_course_2/widgets/MyAlert.dart';


class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
          final User=AuthSeries.firebase().currentUser;
           

            return AppBar(
              actions: [
                PopupMenuButton<MenuAction>(
                  onSelected: (value) async {
                    switch (value) {
                      case MenuAction.logout:
                        final shouldLogout = await showLogOutDialog(context);
                        devTools.log('Should logout: $shouldLogout');
                        if (shouldLogout) {
                          await AuthSeries.firebase().logOut();
                          Navigator.pushNamedAndRemoveUntil(context, loginRoute, (routes) => false);
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text("Log Out"),
                    ),
                  ],
                ),
              ],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text Column for greeting and project count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4), // Small space between texts
                      Row(
                        children: [
                          const Text(
                            'Your Projects',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4), // Space between title and count
                          Text(
                            '(4)', // Project count
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Profile picture on the right side
                  const CircleAvatar(
                    radius: 20, // Size of the profile picture
                    backgroundImage: AssetImage("assets/images (3).jpeg"),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 0, // Remove shadow under AppBar
            );
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}

// Define the MenuAction enum

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return MyAlert(
        text1: "Are you sure you want to log out?",
        text2: "You will be logged out of your account. Please confirm.",
        onConfirm: () {
          Navigator.of(context).pop(true);
          print("true");
        },
        onDismiss: () {
          Navigator.of(context).pop(false);
          print("false");
        },
        buttonText1: "Log Out",
        buttonText2: "Cancel",
      );
    },
  ).then((value) => value ?? false);
}
