import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/friends/domain/repositories/friend_repository.dart';

final getOutgoingRequestsUseCaseProvider = Provider<GetOutgoingRequestsUseCase>((ref) {
  throw UnimplementedError('GetOutgoingRequestsUseCase provider needs repository');
});

class GetOutgoingRequestsUseCase {
  final FriendRepository _repository;

  GetOutgoingRequestsUseCase(this._repository);

  Future<List<dynamic>> call() async {
    return _repository.getOutgoingRequests();
  }
}
