import 'package:dart_either/dart_either.dart';

import '../entities/Message.dart';

abstract interface class DirectRepository {
  Future<Either<String, List<String>>> getParticipants({
    required String chatId,
  });
  Future<Either<String, String>> updateLastReadTimestamp({
    required String chatId,
  });
  Stream<Message?> getLastMessageStream({required String chatId});
  Future<Either<String, String>> submitMessage({
    required String chatId,
    required String message,
  });
  Future<Either<String, String>> editMessage({
    required String chatId,
    required String messageId,
    required String newMessage,
  });
}
