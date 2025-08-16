import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/biometric.dart';
import 'package:flutter_application_1/core/navigation.dart';
import 'package:flutter_application_1/UI/home.dart';
import 'package:flutter_application_1/UI/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasLoggedInBefore = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasLoggedInBefore = prefs.getBool('hasLoggedIn') ?? false;
      debugPrint(_hasLoggedInBefore.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      home: _hasLoggedInBefore ? const BiometricPage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/biometric': (context) => const BiometricPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
