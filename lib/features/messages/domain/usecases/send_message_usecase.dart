import 'package:locket/features/messages/domain/entities/message.dart';
import 'package:locket/features/messages/domain/repositories/message_repository.dart';

final class SendMessageUseCase {
  final MessageRepository _repository;
  SendMessageUseCase(this._repository);

  Future<Message> call(String conversationId, String content) =>
      _repository.sendMessage(conversationId, content);
}
