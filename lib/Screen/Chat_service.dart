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
  // Deployed Render socket server
  static const String serverUrl = 'https://privchat-q0lc.onrender.com';

  bool get isConnected => _socket?.connected ?? false;

  /// Connect once when app starts. Safe to call multiple times.
  Future<bool> connect() async {
    if (_socket != null && _socket!.connected) return true;

    final completer = Completer<bool>();

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          // Render free instances can be cold and slow to wake;
          // allow more time and retries to avoid spurious failures.
          .disableAutoConnect()
          .setTimeout(20000)
          .setReconnectionAttempts(10)
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

    Future.delayed(const Duration(seconds: 20), () {
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
    // Ensure we are connected before trying to join
    if (!isConnected) {
      final ok = await connect();
      if (!ok) {
        return 'Unable to reach chat server. Please try again in a moment.';
      }
    }

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

  /// Inform the server that we intentionally left the room.
  void leaveRoom(String room) {
    if (!isConnected) return;
    _socket!.emit('leave_room', room);
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