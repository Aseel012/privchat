import 'package:flutter/material.dart';
import 'dart:math';
import 'chatscreen.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

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
          style: TextStyle(color: Color(0xFFF2DFD8), fontSize: 22, fontWeight: FontWeight.bold),
        ),
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
          final code = _generateCode();
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