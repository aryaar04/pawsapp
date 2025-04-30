import 'package:flutter/material.dart';
// Your provided HomePage
import 'login_signup.dart'; // New login/signup page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paws App',
      theme: ThemeData(
        fontFamily: 'Jua',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF95D2B3)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginSignupPage(),
    );
  }
}
