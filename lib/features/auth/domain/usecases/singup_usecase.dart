import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/features/auth/domain/repositories/auth_repository.dart';

import '../../../../service_locator.dart';

class SignUpUseCase {
  Future<Either> handleSignUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    return await sl<AuthRepository>().handleSignUp(
      email: email,
      password: password,
      nickname: nickname,
    );
  }
}
