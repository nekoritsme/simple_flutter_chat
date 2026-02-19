import 'package:dart_either/dart_either.dart';

import '../entities/Message.dart';

abstract interface class DirectRepository {
  Future<Either<String, List<String>>> getParticipants(String chatId);
  Future<Either<String, String>> updateLastReadTimestamp(String chatId);
  Stream<Message?> getLastMessageStream(String chatId);
  Future<Either<String, String>> submitMessage(String chatId, String message);
  Future<Either<String, String>> editMessage(
    String chatId,
    String messageId,
    String newMessage,
  );
}
