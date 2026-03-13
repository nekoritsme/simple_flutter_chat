import 'package:simple_flutter_chat/features/direct/domain/repositories/direct_messages_controller_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class FindMessageIdReturnNicknameUseCase {
  String call({required String messageId}) {
    return sl<DirectMessagesControllerRepository>()
        .findByMessageIdAndReturnNickname(messageId: messageId);
  }
}
