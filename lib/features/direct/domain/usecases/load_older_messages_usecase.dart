import 'package:simple_flutter_chat/service_locator.dart';

import '../repositories/direct_messages_controller_repository.dart';

class LoadOlderMessagesUseCase {
  Future<void> loadOlderMessages() async {
    await sl<DirectMessagesControllerRepository>().loadNextPage();
  }
}
