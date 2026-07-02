import 'package:leaf_cloud/models/user_model.dart';

abstract class IAuthRepository {
  Future<LoginResponse> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<void> logout(String accessToken, String refreshToken);
  Future<LoginResponse> refresh(String refreshToken);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<User> updateProfile(
    String accessToken, {
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  });
}

