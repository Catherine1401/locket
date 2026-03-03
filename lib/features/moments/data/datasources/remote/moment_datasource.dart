import 'package:locket/features/moments/domain/entities/moment.dart';

abstract interface class MomentDatasource {
  Future<Moment?> createMoment(String filePath, String? caption);
}
