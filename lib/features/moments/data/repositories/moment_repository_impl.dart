import 'package:locket/features/moments/data/datasources/remote/moment_datasource.dart';
import 'package:locket/features/moments/domain/entities/moment.dart';
import 'package:locket/features/moments/domain/repositories/moment_repository.dart';

final class MomentRepositoryImpl implements MomentRepository {
  final MomentDatasource _datasource;
  MomentRepositoryImpl(this._datasource);

  @override
  Future<Moment?> createMoment(String filePath, String? caption) =>
      _datasource.createMoment(filePath, caption);
}
