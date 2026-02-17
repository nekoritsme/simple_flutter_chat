import 'package:dart_either/dart_either.dart';

abstract interface class AuthRepository {
  Future<Either> handleSignUp({
    required String email,
    required String password,
    required String nickname,
  });
  Future<Either> handleLogin({required String email, required String password});

  void handleLogout();
}
