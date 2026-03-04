import 'package:locket/features/moments/data/datasources/remote/moment_datasource.dart';
import 'package:locket/features/moments/domain/entities/moment.dart';
import 'package:locket/features/moments/domain/entities/moment_page.dart';
import 'package:locket/features/moments/domain/repositories/moment_repository.dart';

final class MomentRepositoryImpl implements MomentRepository {
  final MomentDatasource _datasource;
  MomentRepositoryImpl(this._datasource);

  @override
  Future<Moment?> createMoment(String filePath, String? caption) =>
      _datasource.createMoment(filePath, caption);

  @override
  Future<MomentPage> getFeed({String? nextCursor}) =>
      _datasource.getFeed(nextCursor: nextCursor);

  @override
  Future<MomentPage> getFeedByUser(String userId, {String? nextCursor}) =>
      _datasource.getFeedByUser(userId, nextCursor: nextCursor);

  @override
  Future<MomentPage> getMyFeed({String? nextCursor}) =>
      _datasource.getMyFeed(nextCursor: nextCursor);

  @override
  Future<GridPage> getGrid({String? nextCursor}) =>
      _datasource.getGrid(nextCursor: nextCursor);

  @override
  Future<GridPage> getGridByUser(String userId, {String? nextCursor}) =>
      _datasource.getGridByUser(userId, nextCursor: nextCursor);

  @override
  Future<GridPage> getMyGrid({String? nextCursor}) =>
      _datasource.getMyGrid(nextCursor: nextCursor);
}
