import 'package:simple_flutter_chat/features/auth/domain/repositories/auth_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class SignOutUsecase {
  Future<void> handleSignOut() async {
    await sl<AuthRepository>().handleLogout();
  }
}
