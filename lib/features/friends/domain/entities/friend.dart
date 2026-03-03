final class Friend {
  final String id;
  final String userId;
  final String name;
  final String? avatar;

  const Friend({
    required this.id,
    required this.userId,
    required this.name,
    this.avatar,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    avatar: json['avatar'] as String?,
  );

  @override
  String toString() => 'Friend{id: $id, userId: $userId, name: $name}';
}
