import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Singleton — one socket for the entire app lifetime.
/// The socket is NEVER killed when navigating between screens.
class ChatService {
  ChatService._internal();
  static final ChatService instance = ChatService._internal();
  factory ChatService() => instance;

  IO.Socket? _socket;

  // ✅ PRODUCTION:
  // Set this to your deployed socket server, e.g.:
  //   'https://your-chat-backend.example.com'
  //
  // ✅ LOCAL TESTING:
  // Use your PC IP **with port 3000**, e.g.:
  //   'http://192.168.X.X:3000'
  //
  // NOTE: Missing ":3000" here will cause the app
  // to stay stuck on "Setting up room..." because
  // it will try to connect on port 80 where your
  // Node server is not listening.
  static const String serverUrl = 'http://192.168.1.8:3000';

  bool get isConnected => _socket?.connected ?? false;

  /// Connect once when app starts. Safe to call multiple times.
  Future<bool> connect() async {
    if (_socket != null && _socket!.connected) return true;

    final completer = Completer<bool>();

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setTimeout(8000)
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ ChatService connected: ${_socket!.id}');
      if (!completer.isCompleted) completer.complete(true);
    });

    _socket!.onConnectError((e) {
      print('❌ ChatService connect error: $e');
      if (!completer.isCompleted) completer.complete(false);
    });

    _socket!.onReconnect((_) => print('🔄 Reconnected'));
    _socket!.onDisconnect((_) => print('🔌 ChatService disconnected'));

    _socket!.connect();

    Future.delayed(const Duration(seconds: 8), () {
      if (!completer.isCompleted) completer.complete(false);
    });

    return completer.future;
  }

  /// Host: register room on server
  Future<bool> createRoom(String room) async {
    final completer = Completer<bool>();

    _socket!.emitWithAck('create_room', room, ack: (response) {
      completer.complete(true);
    });

    // Fallback
    Future.delayed(const Duration(seconds: 3), () {
      if (!completer.isCompleted) completer.complete(true);
    });

    return completer.future;
  }

  /// Guest: join a room — returns null on success, error string on failure
  Future<String?> joinRoom(String room) async {
    final completer = Completer<String?>();

    final timer = Timer(const Duration(seconds: 8), () {
      if (!completer.isCompleted) {
        completer.complete('Timed out. Make sure your friend opened the app first.');
      }
    });

    _socket!.emitWithAck('join_room', room, ack: (response) {
      timer.cancel();
      if (completer.isCompleted) return;
      print('📥 join_room: $response');

      if (response is Map && response['success'] == true) {
        completer.complete(null);
      } else if (response is Map) {
        completer.complete(response['error']?.toString() ?? 'Failed to join');
      } else {
        completer.complete('No response from server');
      }
    });

    return completer.future;
  }

  void sendMessage(String room, String message) {
    _socket!.emit('send_message', {'room': room, 'message': message});
  }

  void on(String event, Function(dynamic) handler) {
    _socket!.on(event, handler);
  }

  void off(String event) {
    _socket!.off(event);
  }

  /// Only call this when truly leaving (app close)
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}