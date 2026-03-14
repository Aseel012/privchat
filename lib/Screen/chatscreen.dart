import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_service.dart';
import 'chatroom.dart';

class Chatscreen extends StatefulWidget {
  final String roomCode;
  const Chatscreen({super.key, required this.roomCode});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final TextEditingController _joinController = TextEditingController();
  final ChatService _chat = ChatService.instance;

  bool _roomReady = false;
  bool _isJoining = false;
  String? _roomError;

  @override
  void initState() {
    super.initState();
    _registerRoom();
  }

  Future<void> _registerRoom() async {
    // Reset state
    setState(() {
      _roomReady = false;
      _roomError = null;
    });

    // Ensure connected (already connected in main, but just in case)
    final ok = _chat.isConnected ? true : await _chat.connect();
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _roomError =
            "Unable to reach chat server.\nCheck your internet / server URL and try again.";
      });
      return;
    }

    await _chat.createRoom(widget.roomCode);
    if (!mounted) return;
    setState(() => _roomReady = true);
    print('🏠 Room ready: ${widget.roomCode}');
  }

  Future<void> _joinChat() async {
    final code = _joinController.text.trim().toUpperCase();

    if (code.isEmpty) { _snack("Please enter a code"); return; }
    if (code == widget.roomCode) { _snack("Cannot join your own room"); return; }

    setState(() => _isJoining = true);

    final error = await _chat.joinRoom(code);

    if (!mounted) return;
    setState(() => _isJoining = false);

    if (error == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Chatroom(roomCode: code, isHost: false)),
      );
    } else {
      _snack(error, isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade700 : null,
      duration: Duration(seconds: isError ? 5 : 2),
    ));
  }

  @override
  void dispose() {
    _joinController.dispose();
    // ⚠️ Do NOT disconnect here — singleton must stay alive
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF211D2D),
        iconTheme: const IconThemeData(color: Color(0xFFF2DFD8)),
        title: const Text("New Chat", style: TextStyle(color: Color(0xFFF2DFD8))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _roomReady
                      ? Icons.cloud_done
                      : _roomError != null
                          ? Icons.error_outline
                          : Icons.cloud_off,
                  color: _roomReady
                      ? Colors.greenAccent
                      : _roomError != null
                          ? Colors.redAccent
                          : Colors.grey,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _roomReady
                      ? "Room active — share your code"
                      : _roomError ?? "Setting up room...",
                  style: TextStyle(
                    color: _roomReady
                        ? Colors.greenAccent
                        : _roomError != null
                            ? Colors.redAccent
                            : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Your code
            const Text("Your Room Code",
                style: TextStyle(color: Color(0xFFF2DFD8), fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF353839),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.roomCode,
                style: const TextStyle(
                  color: Colors.white, fontSize: 30,
                  letterSpacing: 8, fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _smallButton(
                  icon: Icons.copy,
                  label: "Copy",
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.roomCode));
                    _snack("Code copied!");
                  },
                ),
                const SizedBox(width: 10),
                _smallButton(
                  icon: Icons.meeting_room,
                  label: "Enter My Room",
                  color: const Color(0xFF6C63FF),
                  onTap: _roomReady
                      ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Chatroom(
                        roomCode: widget.roomCode,
                        isHost: true,
                      ),
                    ),
                  )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Row(children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("OR JOIN A FRIEND", style: TextStyle(color: Colors.white38, fontSize: 11)),
              ),
              Expanded(child: Divider(color: Colors.white24)),
            ]),
            const SizedBox(height: 24),

            TextField(
              controller: _joinController,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "Enter friend's 6-digit code",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF353839),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isJoining ? null : _joinChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  disabledBackgroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isJoining
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                    SizedBox(width: 12),
                    Text("Joining...", style: TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                )
                    : const Text("Join Chat",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFF353839),
          disabledBackgroundColor: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon, color: Colors.white, size: 15),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }
}