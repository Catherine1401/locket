import 'package:locket/features/messages/domain/entities/conversation.dart';
import 'package:locket/features/messages/domain/entities/message.dart';

abstract interface class MessageDatasource {
  Future<List<Conversation>> getConversations();
  Future<({List<Message> messages, String? nextCursor})> getMessages(
    String conversationId, {
    String? nextCursor,
  });
  Future<Message> sendMessage(String conversationId, String content);
}
