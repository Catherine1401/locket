import 'package:locket/features/moments/domain/entities/moment_page.dart';
import 'package:locket/features/moments/domain/repositories/moment_repository.dart';

class GetGridUseCase {
  final MomentRepository _repo;
  GetGridUseCase(this._repo);

  Future<GridPage> call({String? nextCursor, String? filterUserId}) {
    if (filterUserId != null) {
      return _repo.getGridByUser(filterUserId, nextCursor: nextCursor);
    }
    return _repo.getGrid(nextCursor: nextCursor);
  }
}
