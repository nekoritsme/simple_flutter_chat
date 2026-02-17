import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/features/auth/domain/repositories/auth_repository.dart';

import '../../../../service_locator.dart';

class LoginUseCase {
  Future<Either> handleLogin({
    required String email,
    required String password,
  }) async {
    return sl<AuthRepository>().handleLogin(email: email, password: password);
  }
}
