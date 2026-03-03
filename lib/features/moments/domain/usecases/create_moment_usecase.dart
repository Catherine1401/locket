import 'package:locket/features/moments/domain/entities/moment.dart';
import 'package:locket/features/moments/domain/repositories/moment_repository.dart';

final class CreateMomentUseCase {
  final MomentRepository _repository;
  CreateMomentUseCase(this._repository);

  static const int _maxCaptionWords = 100;

  Future<Moment?> call(String filePath, String? caption) {
    final normalizedCaption = _normalizeCaption(caption);
    if (normalizedCaption != null &&
        _countWords(normalizedCaption) > _maxCaptionWords) {
      throw const FormatException('Caption tối đa 100 từ');
    }
    return _repository.createMoment(filePath, normalizedCaption);
  }

  static String? _normalizeCaption(String? caption) {
    final trimmed = caption?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static int _countWords(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
}
