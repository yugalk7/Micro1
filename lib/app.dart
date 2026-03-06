import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';

class ArogyaApp extends StatelessWidget {
  const ArogyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arogya 2.0',
      debugShowCheckedModeBanner: false,

      supportedLocales: const [Locale('en'), Locale('hi')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),

      home: const HomeScreen(),
    );
  }
}
