import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/service_locator.dart';

import '../repositories/direct_repository.dart';

class DeleteMessageUseCase {
  Future<Either<String, String>> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    return sl<DirectRepository>().deleteMessage(
      chatId: chatId,
      messageId: messageId,
    );
  }
}
