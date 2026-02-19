import 'package:simple_flutter_chat/service_locator.dart';
import 'package:simple_flutter_chat/shared/domain/entities/user.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/user_repository.dart';

class GetCurrentUserUseCase {
  UserEntity getUser() {
    return sl<UserRepository>().currentUser;
  }
}
