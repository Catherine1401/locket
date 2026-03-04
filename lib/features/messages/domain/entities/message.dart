class ReplyMoment {
  final String id;
  final String? imageUrl;
  final DateTime? createdAt;
  final String? authorName;
  final String? authorAvatar;

  const ReplyMoment({
    required this.id,
    this.imageUrl,
    this.createdAt,
    this.authorName,
    this.authorAvatar,
  });

  factory ReplyMoment.fromJson(Map<String, dynamic> json) => ReplyMoment(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        authorName: json['authorName'] as String?,
        authorAvatar: json['authorAvatar'] as String?,
      );
}

final class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isDeleted;
  final ReplyMoment? replyToMoment;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isDeleted = false,
    this.replyToMoment,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        senderId: json['senderId'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isDeleted: json['isDeleted'] as bool? ?? false,
        replyToMoment: json['replyToMoment'] != null
            ? ReplyMoment.fromJson(json['replyToMoment'] as Map<String, dynamic>)
            : null,
      );
}
