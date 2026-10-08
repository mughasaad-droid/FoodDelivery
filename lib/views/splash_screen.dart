import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 4 second ka timer taake splash screen ke baad Intro Screen par jaye
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthIntroScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFaf1), // Aapka provide kiya hua background color
      body: Center(
        child: Image.asset(
          'assets/splash.gif',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
