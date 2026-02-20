import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/service_locator.dart';

import '../repositories/direct_repository.dart';

class UpdateLastReadTimestampUseCase {
  Future<Either<String, String>> updateLastReadTimestamp({
    required String chatId,
  }) async {
    return await sl<DirectRepository>().updateLastReadTimestamp(chatId: chatId);
  }
}
