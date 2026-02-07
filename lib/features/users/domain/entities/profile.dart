final class Profile {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String? birthday;

  const Profile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.birthday,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'],
    email: json['email'],
    displayName: json['displayName'],
    avatarUrl: json['avatarUrl'],
    birthday: json['birthday'],
  );

  Profile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? birthday,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthday: birthday ?? this.birthday,
    );
  }

  @override
  String toString() {
    return 'Profile{id: $id, email: $email, displayName: $displayName, avatarUrl: $avatarUrl, birthday: $birthday}';
  }
}
