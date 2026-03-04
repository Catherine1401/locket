import 'package:locket/features/messages/domain/repositories/message_repository.dart';

class MarkReadUseCase {
  final MessageRepository _repo;
  MarkReadUseCase(this._repo);

  Future<void> call(String conversationId) => _repo.markRead(conversationId);
}
