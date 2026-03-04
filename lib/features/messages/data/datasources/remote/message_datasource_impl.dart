import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:locket/features/messages/data/datasources/remote/message_datasource.dart';
import 'package:locket/features/messages/domain/entities/conversation.dart';
import 'package:locket/features/messages/domain/entities/message.dart';

final class MessageDatasourceImpl implements MessageDatasource {
  final Dio _dio;
  MessageDatasourceImpl(this._dio);

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dio.get('/conversations/me');
      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        return list
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('MessageDatasourceImpl.getConversations error: $e');
      return [];
    }
  }

  @override
  Future<({List<Message> messages, String? nextCursor})> getMessages(
    String conversationId, {
    String? nextCursor,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': 30};
      if (nextCursor != null) queryParams['nextcursor'] = nextCursor;

      final response = await _dio.get(
        '/conversations/$conversationId/messages',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final list = (data['messages'] as List<dynamic>)
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
        final cursor = data['nextCursor'] as String?;
        return (messages: list, nextCursor: cursor);
      }
      return (messages: <Message>[], nextCursor: null);
    } catch (e) {
      debugPrint('MessageDatasourceImpl.getMessages error: $e');
      return (messages: <Message>[], nextCursor: null);
    }
  }

  @override
  Future<Message> sendMessage(String conversationId, String content, {String? replyToMomentId}) async {
    final data = <String, dynamic>{
      'conversationId': conversationId,
      'content': content,
    };
    if (replyToMomentId != null) {
      data['replyToMomentId'] = replyToMomentId;
    }
    final response = await _dio.post(
      '/messages',
      data: data,
    );
    return Message.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> markRead(String conversationId) async {
    try {
      await _dio.put('/conversations/$conversationId/read');
    } catch (e) {
      // Mark read failure is non-critical  
    }
  }
}
