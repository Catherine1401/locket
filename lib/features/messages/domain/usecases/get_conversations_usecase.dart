import 'package:locket/features/messages/domain/entities/conversation.dart';
import 'package:locket/features/messages/domain/repositories/message_repository.dart';

final class GetConversationsUseCase {
  final MessageRepository _repository;
  GetConversationsUseCase(this._repository);

  Future<List<Conversation>> call() => _repository.getConversations();
}
