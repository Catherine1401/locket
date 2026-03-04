import 'package:locket/features/moments/domain/entities/moment.dart';
import 'package:locket/features/moments/domain/entities/moment_page.dart';

abstract interface class MomentRepository {
  Future<Moment?> createMoment(String filePath, String? caption);

  Future<MomentPage> getFeed({String? nextCursor, String? prevCursor});
  Future<MomentPage> getFeedByUser(String userId, {String? nextCursor, String? prevCursor});
  Future<MomentPage> getMyFeed({String? nextCursor, String? prevCursor});

  Future<GridPage> getGrid({String? nextCursor});
  Future<GridPage> getGridByUser(String userId, {String? nextCursor});
  Future<GridPage> getMyGrid({String? nextCursor});
}
