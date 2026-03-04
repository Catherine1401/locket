import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import 'package:locket/features/messages/domain/entities/message.dart';

class SocketService {
  sio.Socket? _socket;

  /// Kết nối đến Socket.IO server với JWT access token
  void connect(String serverUrl, String accessToken) {
    if (_socket != null && _socket!.connected) return;

    _socket = sio.io(
      serverUrl,
      sio.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': accessToken})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] Connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected');
    });

    _socket!.onConnectError((err) {
      debugPrint('[Socket] Connect error: $err');
    });

    _socket!.connect();
  }

  /// Join vào room của một conversation để nhận real-time messages
  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', conversationId);
  }

  /// Rời khỏi room của một conversation
  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', conversationId);
  }

  /// Lắng nghe tin nhắn mới trong conversation hiện tại.
  /// Trả về Stream của [Message] để ChatProvider subscribe.
  Stream<Message> onNewMessage() {
    if (_socket == null) return const Stream.empty();

    // socket_io_client dùng callback-based API, nên ta wrap bằng StreamController
    final controller = StreamController<Message>.broadcast();

    _socket!.on('new_message', (data) {
      try {
        final msg = Message.fromJson(Map<String, dynamic>.from(data as Map));
        if (!controller.isClosed) controller.add(msg);
      } catch (e) {
        debugPrint('[Socket] Error parsing new_message: $e');
      }
    });

    return controller.stream;
  }

  bool get isConnected => _socket?.connected ?? false;

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
