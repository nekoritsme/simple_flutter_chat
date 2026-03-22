import '../../../../service_locator.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/domain/repositories/user_repository.dart';

class GetSpecificUserStreamUseCase {
  Stream<UserEntity> getSpecificUserStream({required String uid}) {
    return sl<UserRepository>().specificUserStream(uid: uid);
  }
}
