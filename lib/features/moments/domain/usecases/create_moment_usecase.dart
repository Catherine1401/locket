import 'package:locket/features/moments/domain/entities/moment.dart';
import 'package:locket/features/moments/domain/repositories/moment_repository.dart';

final class CreateMomentUseCase {
  final MomentRepository _repository;
  CreateMomentUseCase(this._repository);

  Future<Moment?> call(String filePath, String? caption) =>
      _repository.createMoment(filePath, caption);
}
