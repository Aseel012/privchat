import 'package:chat/Screen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'Screen/chat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Connect socket once at app start — stays alive across all screens
  await ChatService.instance.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PrivChat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Splashscreen(),
    );
  }
}