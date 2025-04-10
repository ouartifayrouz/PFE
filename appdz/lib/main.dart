import 'package:flutter/material.dart';
import 'package:dztrainfay/CreatePasswordScreen.dart';
import 'package:dztrainfay/ForgotPasswordScreen.dart';
import 'package:dztrainfay/PasswordChangedScreen.dart';
import 'package:dztrainfay/SignInScreen.dart';
import 'package:dztrainfay/SignUpScreen.dart';
import 'package:dztrainfay/VerifyEmailScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dztrainfay/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

  runApp(MyApp(onboardingSeen: onboardingSeen));
}

class MyApp extends StatelessWidget {
  final bool onboardingSeen;

  MyApp({required this.onboardingSeen}); // Passer la variable ici

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: onboardingSeen ? SignInScreen() : OnboardingScreen(), // Utiliser onboardingSeen
      routes: {
        '/signup': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/verify-email': (context) => VerifyEmailScreen(verificationCode: 0, email: ''),
        '/create-password': (context) => CreatePasswordScreen(),
        '/password-changed': (context) => PasswordChangedScreen(),
      },
    );
  }
}