import 'package:locket/features/messages/domain/entities/message.dart';
import 'package:locket/features/messages/domain/repositories/message_repository.dart';

final class GetMessagesUseCase {
  final MessageRepository _repository;
  GetMessagesUseCase(this._repository);

  Future<({List<Message> messages, String? nextCursor})> call(
    String conversationId, {
    String? nextCursor,
  }) =>
      _repository.getMessages(conversationId, nextCursor: nextCursor);
}
