import '../../../../service_locator.dart';
import '../../../../shared/domain/repositories/user_repository.dart';

class GetNicknameUseCase {
  Future<String> getNickname() async {
    return await sl<UserRepository>().nickname;
  }
}
