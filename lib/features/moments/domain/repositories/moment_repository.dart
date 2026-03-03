import 'package:locket/features/moments/domain/entities/moment.dart';

abstract interface class MomentRepository {
  Future<Moment?> createMoment(String filePath, String? caption);
}
