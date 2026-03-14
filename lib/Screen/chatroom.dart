import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatMessage {
  final String text;
  final bool isMine;
  ChatMessage({required this.text, required this.isMine});
}

class Chatroom extends StatefulWidget {
  final String roomCode;
  final bool isHost;

  const Chatroom({super.key, required this.roomCode, required this.isHost});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ChatService _chat = ChatService.instance;
  bool _peerOnline = false;

  @override
  void initState() {
    super.initState();

    if (widget.isHost) {
      _chat.on('user_joined', (_) {
        if (!mounted) return;
        setState(() => _peerOnline = true);
        _sysMsg("Friend joined ✓");
      });
    } else {
      // Guest — already joined, peer is the host
      setState(() => _peerOnline = true);
    }

    _chat.on('receive_message', (data) {
      if (!mounted) return;
      setState(() => _messages.add(ChatMessage(text: data.toString(), isMine: false)));
      _scrollDown();
    });

    _chat.on('user_left', (_) {
      if (!mounted) return;
      setState(() => _peerOnline = false);
      _sysMsg("Friend left the chat");
    });
  }

  @override
  void dispose() {
    // Remove listeners but keep socket alive (singleton)
    _chat.off('user_joined');
    _chat.off('receive_message');
    _chat.off('user_left');
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sysMsg(String text) {
    setState(() => _messages.add(ChatMessage(text: '— $text —', isMine: false)));
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _chat.sendMessage(widget.roomCode, text);
    setState(() => _messages.add(ChatMessage(text: text, isMine: true)));
    _msgController.clear();
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF211D2D),
        iconTheme: const IconThemeData(color: Color(0xFFF2DFD8)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.roomCode,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Row(children: [
              Container(
                width: 7, height: 7,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _peerOnline ? Colors.greenAccent : Colors.grey,
                ),
              ),
              Text(
                _peerOnline
                    ? "Connected"
                    : widget.isHost ? "Waiting for friend..." : "Connecting...",
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ]),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Text(
                widget.isHost
                    ? "Share your code and wait\nfor your friend to join"
                    : "Connected! Say hello 👋",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          Container(
            color: const Color(0xFF1A1625),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF353839),
                    hintText: "Message...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF),
                child: IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _bubble(ChatMessage msg) {
    // System message
    if (msg.text.startsWith('—') && msg.text.endsWith('—')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Text(msg.text,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic)),
        ),
      );
    }
    return Align(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: msg.isMine ? const Color(0xFF6C63FF) : const Color(0xFF353839),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMine ? 16 : 4),
            bottomRight: Radius.circular(msg.isMine ? 4 : 16),
          ),
        ),
        child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }
}