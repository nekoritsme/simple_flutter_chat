import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/service_locator.dart';

import '../repositories/direct_repository.dart';

class EditMessageUseCase {
  Future<Either<String, String>> editMessage({
    required String chatId,
    required String messageId,
    required String newMessage,
  }) async {
    return sl<DirectRepository>().editMessage(
      chatId: chatId,
      messageId: messageId,
      newMessage: newMessage,
    );
  }
}
