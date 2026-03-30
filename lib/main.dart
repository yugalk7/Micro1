import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'core/theme.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();


await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

runApp(const ArogyaApp());
}

class ArogyaApp extends StatelessWidget {
const ArogyaApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Arogya',
debugShowCheckedModeBanner: false,
theme: AppTheme.lightTheme,


  home: StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (snapshot.hasData) {
        return const MainNavigation();
      }

      return const LoginScreen();
    },
  ),
);

}
}
