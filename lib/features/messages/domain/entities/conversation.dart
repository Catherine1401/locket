final class Conversation {
  final String id;
  final String partnerId;
  final String partnerName;
  final String? partnerAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isUnread;

  const Conversation({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatar,
    this.lastMessage,
    this.lastMessageAt,
    this.isUnread = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        partnerId: json['partnerId'] as String,
        partnerName: json['partnerName'] as String,
        partnerAvatar: json['partnerAvatar'] as String?,
        lastMessage: json['lastMessage'] as String?,
        lastMessageAt: json['lastMessageAt'] != null
            ? DateTime.parse(json['lastMessageAt'] as String)
            : null,
        isUnread: json['isUnread'] as bool? ?? false,
      );

  Conversation copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    bool? isUnread,
  }) =>
      Conversation(
        id: id,
        partnerId: partnerId,
        partnerName: partnerName,
        partnerAvatar: partnerAvatar,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        isUnread: isUnread ?? this.isUnread,
      );
}
