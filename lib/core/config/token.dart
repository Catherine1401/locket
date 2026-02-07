final class Token {
  String? accessToken;
  String? refreshToken;

  Token({this.accessToken, this.refreshToken});

  factory Token.fromJson(Map<String, dynamic> json) => Token(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
  );

  @override
  String toString() {
    return 'Token{accessToken: $accessToken, refreshToken: $refreshToken}';
  }
}
