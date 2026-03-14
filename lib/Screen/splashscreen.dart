import 'package:chat/Screen/homescreen.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    splashTimer();
  }

  void splashTimer() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Homescreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF211D2D),
      body: Center(
        child: Text(
          "PRIVCHAT",
          style: TextStyle(
            color: Color(0xFFF2DFD8),
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
        ),
      ),
    );
  }
}