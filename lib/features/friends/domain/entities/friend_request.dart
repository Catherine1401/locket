final class FriendRequest {
  final String id;
  final String userId;
  final String name;
  final String? avatar;

  const FriendRequest({
    required this.id,
    required this.userId,
    required this.name,
    this.avatar,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
    id: json['id'].toString(),
    userId: json['userId'].toString(),
    name: json['name'] as String? ?? 'Người dùng',
    avatar: json['avatar'] as String?,
  );

  @override
  String toString() => 'FriendRequest{id: $id, userId: $userId, name: $name}';
}
