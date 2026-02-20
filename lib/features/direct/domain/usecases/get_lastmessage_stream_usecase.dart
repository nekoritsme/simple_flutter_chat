import 'package:simple_flutter_chat/service_locator.dart';

import '../entities/Message.dart';
import '../repositories/direct_repository.dart';

class GetLastMessageStreamUseCase {
  Stream<Message?> getLastMessageStream(String chatId) {
    return sl<DirectRepository>().getLastMessageStream(chatId);
  }
}
