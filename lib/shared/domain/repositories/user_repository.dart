import 'package:simple_flutter_chat/shared/domain/entities/user.dart';

abstract interface class UserRepository {
  Future<String> get nickname;
  UserEntity get currentUser;
  Stream<UserEntity> specificUserStream({required String uid});
}
