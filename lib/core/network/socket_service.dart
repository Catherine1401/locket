import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import 'package:locket/features/messages/domain/entities/message.dart';

/// Quản lý kết nối Socket.IO và phân phát events qua một broadcast stream duy nhất.
/// Broadcast stream đảm bảo tất cả subscriber (ConversationsNotifier, ChatNotifier)
/// đều nhận events ngay cả khi subscribe trước khi socket kết nối xong.
class SocketService {
  sio.Socket? _socket;

  // Single broadcast StreamController — sống suốt vòng đời của SocketService
  final _messageController = StreamController<Message>.broadcast();

  /// Stream of all incoming new_message events.
  /// Subscribe bất kỳ lúc nào — sẽ nhận messages ngay sau khi socket kết nối.
  Stream<Message> get messageStream => _messageController.stream;

  /// Kết nối đến Socket.IO server với JWT access token
  void connect(String serverUrl, String accessToken) {
    // Nếu đang connected với cùng token thì bỏ qua
    if (_socket != null && _socket!.connected) return;

    // Ngắt kết nối cũ nếu có (đổi tài khoản)
    _socket?.disconnect();
    _socket?.off('new_message');
    _socket = null;

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
      // Đăng ký listener new_message SAU KHI kết nối thành công
      _socket!.on('new_message', (data) {
        try {
          final msg = Message.fromJson(Map<String, dynamic>.from(data as Map));
          if (!_messageController.isClosed) _messageController.add(msg);
        } catch (e) {
          debugPrint('[Socket] Error parsing new_message: $e');
        }
      });
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected');
    });

    _socket!.onConnectError((err) {
      debugPrint('[Socket] Connect error: $err');
    });

    _socket!.connect();
  }

  /// Join vào room của một conversation để nhận real-time messages trong ChatScreen
  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', conversationId);
  }

  /// Rời khỏi room của một conversation
  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', conversationId);
  }

  bool get isConnected => _socket?.connected ?? false;

  void disconnect() {
    _socket?.off('new_message');
    _socket?.disconnect();
    _socket = null;
  }
}
