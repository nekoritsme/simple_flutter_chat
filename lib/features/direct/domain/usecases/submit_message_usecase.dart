import 'package:dart_either/dart_either.dart';

import '../../../../service_locator.dart';
import '../repositories/direct_repository.dart';

class SubmitMessageUseCase {
  Future<Either<String, String>> submitMessage(
    String chatId,
    String message,
  ) async {
    return await sl<DirectRepository>().submitMessage(chatId, message);
  }
}
