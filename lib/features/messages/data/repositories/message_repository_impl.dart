import 'package:locket/features/messages/data/datasources/remote/message_datasource.dart';
import 'package:locket/features/messages/domain/entities/conversation.dart';
import 'package:locket/features/messages/domain/entities/message.dart';
import 'package:locket/features/messages/domain/repositories/message_repository.dart';

final class MessageRepositoryImpl implements MessageRepository {
  final MessageDatasource _datasource;
  MessageRepositoryImpl(this._datasource);

  @override
  Future<List<Conversation>> getConversations() =>
      _datasource.getConversations();

  @override
  Future<({List<Message> messages, String? nextCursor})> getMessages(
    String conversationId, {
    String? nextCursor,
  }) =>
      _datasource.getMessages(conversationId, nextCursor: nextCursor);

  @override
  Future<Message> sendMessage(String conversationId, String content, {String? replyToMomentId}) =>
      _datasource.sendMessage(conversationId, content, replyToMomentId: replyToMomentId);

  @override
  Future<void> markRead(String conversationId) =>
      _datasource.markRead(conversationId);
}
