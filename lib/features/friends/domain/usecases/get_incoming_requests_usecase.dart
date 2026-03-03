import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final getIncomingRequestsUseCaseProvider = Provider<GetIncomingRequestsUseCase>((ref) {
  throw UnimplementedError('GetIncomingRequestsUseCase provider needs repository');
});

class GetIncomingRequestsUseCase {
  final FriendRepository _repository;

  GetIncomingRequestsUseCase(this._repository);

  Future<List<dynamic>> call() async {
    return _repository.getIncomingRequests();
  }
}
