import 'package:simple_flutter_chat/service_locator.dart';

import '../repositories/direct_messages_controller_repository.dart';

class InitMessagesStreamUseCase {
  void init({required String chatId}) {
    sl<DirectMessagesControllerRepository>().init(chatId: chatId);
  }
}
