import 'package:locket/features/moments/domain/entities/moment.dart';

/// Kết quả trả về từ API feed/grid — bao gồm danh sách moments và cursors.
class MomentPage {
  final List<Moment> moments;
  final String? nextCursor;
  final String? prevCursor;
  final bool nextEnd; // true = không còn data cũ hơn
  final bool prevEnd; // true = không còn data mới hơn

  const MomentPage({
    this.moments = const [],
    this.nextCursor,
    this.prevCursor,
    this.nextEnd = true,
    this.prevEnd = true,
  });

  factory MomentPage.empty() => const MomentPage();

  factory MomentPage.fromJson(Map<String, dynamic> json) {
    final rawList = json['moments'] as List<dynamic>? ?? [];
    return MomentPage(
      moments: rawList
          .map((e) => Moment.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor']?.toString(),
      prevCursor: json['prevCursor']?.toString(),
      nextEnd: json['nextEnd'] as bool? ?? true,
      prevEnd: json['prevEnd'] as bool? ?? true,
    );
  }
}

/// Dành riêng cho grid — chỉ có id + thumbnail URL.
class GridMoment {
  final String id;
  final String? thumbnail;

  const GridMoment({required this.id, this.thumbnail});

  factory GridMoment.fromJson(Map<String, dynamic> json) => GridMoment(
        id: json['id'].toString(),
        thumbnail: json['thumbnail'] as String?,
      );
}

class GridPage {
  final List<GridMoment> moments;
  final String? nextCursor;
  final String? prevCursor;
  final bool nextEnd;
  final bool prevEnd;

  const GridPage({
    this.moments = const [],
    this.nextCursor,
    this.prevCursor,
    this.nextEnd = true,
    this.prevEnd = true,
  });

  factory GridPage.empty() => const GridPage();

  factory GridPage.fromJson(Map<String, dynamic> json) {
    final rawList = json['moments'] as List<dynamic>? ?? [];
    return GridPage(
      moments: rawList
          .map((e) => GridMoment.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor']?.toString(),
      prevCursor: json['prevCursor']?.toString(),
      nextEnd: json['nextEnd'] as bool? ?? true,
      prevEnd: json['prevEnd'] as bool? ?? true,
    );
  }
}
