import 'package:dart_either/dart_either.dart';

import '../../../../service_locator.dart';
import '../repositories/direct_repository.dart';

class SendImageUseCase {
  Future<Either<String, String>> call({
    required String chatId,
    required String? replyMessageId,
    required String? replyMessage,
  }) {
    return sl<DirectRepository>().sendImage(
      chatId: chatId,
      replyMessageId: replyMessageId,
      replyMessage: replyMessage,
    );
  }
}
