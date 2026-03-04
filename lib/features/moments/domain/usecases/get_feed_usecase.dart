import 'package:locket/features/moments/domain/entities/moment_page.dart';
import 'package:locket/features/moments/domain/repositories/moment_repository.dart';

class GetFeedUseCase {
  final MomentRepository _repo;
  GetFeedUseCase(this._repo);

  Future<MomentPage> call({String? nextCursor, String? prevCursor, String? filterUserId}) {
    if (filterUserId != null) {
      return _repo.getFeedByUser(filterUserId, nextCursor: nextCursor, prevCursor: prevCursor);
    }
    return _repo.getFeed(nextCursor: nextCursor, prevCursor: prevCursor);
  }
}
