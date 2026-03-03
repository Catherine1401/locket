final class Moment {
  final String id;
  final String imageUrl;
  final String? caption;
  final String userId;
  final DateTime createdAt;

  const Moment({
    required this.id,
    required this.imageUrl,
    this.caption,
    required this.userId,
    required this.createdAt,
  });

  factory Moment.fromJson(Map<String, dynamic> json) => Moment(
    id: json['id'].toString(),
    imageUrl: json['imageUrl'] as String,
    caption: json['caption'] as String?,
    userId: json['userId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  @override
  String toString() =>
      'Moment{id: $id, imageUrl: $imageUrl, caption: $caption, userId: $userId}';
}
