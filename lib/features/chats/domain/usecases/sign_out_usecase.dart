import 'package:simple_flutter_chat/features/auth/domain/repositories/auth_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class SignOutUsecase {
  void handleSignOut() {
    sl<AuthRepository>().handleLogout();
  }
}
