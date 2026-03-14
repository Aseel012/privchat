import 'package:flutter/material.dart';
import 'chatscreen.dart';
import '../utils/room_code.dart';
import 'settings_screen.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF211D2D),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "PRIVCHAT",
          style: TextStyle(
            color: Color(0xFFF2DFD8),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFF2DFD8)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: Color(0xFFF2DFD8), size: 64),
            SizedBox(height: 20),
            Text("Private 1:1 Chat",
                style: TextStyle(color: Color(0xFFF2DFD8), fontSize: 24, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text("Tap + to create a new chat room",
                style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final code = generateRoomCode();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Chatscreen(roomCode: code)),
          );
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}