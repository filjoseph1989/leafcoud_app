class User {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.isVerified = false,
  });

  User copyWith({
    String? name,
    String? email,
    bool? isAdmin,
    bool? isVerified,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isAdmin: json['is_admin'] ?? false,
      isVerified: json['is_verified'] ?? false,
    );
  }
}

class LoginResponse {
  final String status;
  final String token;
  final String? refreshToken;
  final String message;
  final User? user;

  LoginResponse({
    required this.status,
    required this.token,
    this.refreshToken,
    required this.message,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      token: json['token'],
      refreshToken: json['refresh_token'],
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
