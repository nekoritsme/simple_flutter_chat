import 'package:simple_flutter_chat/features/direct/domain/presentation/direct_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

import '../entities/Message.dart';

class GetLastMessageStreamUseCase {
  Stream<Message?> getLastMessageStream(String chatId) {
    return sl<DirectRepository>().getLastMessageStream(chatId);
  }
}
