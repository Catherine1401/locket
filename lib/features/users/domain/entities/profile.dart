final class Profile {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String? birthday;
  final String? shareCode;

  const Profile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.birthday,
    this.shareCode,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'],
    email: json['email'],
    displayName: json['displayName'],
    avatarUrl: json['avatarUrl'],
    birthday: json['birthday'],
    shareCode: json['shareCode'],
  );

  Profile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? birthday,
    String? shareCode,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthday: birthday ?? this.birthday,
      shareCode: shareCode ?? this.shareCode,
    );
  }

  @override
  String toString() {
    return 'Profile{id: $id, email: $email, displayName: $displayName, avatarUrl: $avatarUrl, birthday: $birthday, shareCode: $shareCode}';
  }
}
