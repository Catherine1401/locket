import 'package:locket/features/moments/domain/entities/moment_page.dart';
import 'package:locket/features/moments/domain/entities/moment.dart';

abstract interface class MomentDatasource {
  Future<Moment?> createMoment(String filePath, String? caption);

  /// Lấy feed (bạn bè + bản thân). Truyền nextCursor để load thêm cũ hơn.
  Future<MomentPage> getFeed({String? nextCursor, String? prevCursor});

  /// Feed theo user cụ thể (phải là bạn bè).
  Future<MomentPage> getFeedByUser(String userId, {String? nextCursor, String? prevCursor});

  /// Feed của bản thân.
  Future<MomentPage> getMyFeed({String? nextCursor, String? prevCursor});

  /// Grid tất cả (thumbnail). Truyền nextCursor để load thêm.
  Future<GridPage> getGrid({String? nextCursor});

  /// Grid theo user cụ thể.
  Future<GridPage> getGridByUser(String userId, {String? nextCursor});

  /// Grid của bản thân.
  Future<GridPage> getMyGrid({String? nextCursor});
}
