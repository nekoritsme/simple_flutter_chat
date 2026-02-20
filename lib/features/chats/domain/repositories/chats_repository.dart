import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/features/chats/domain/entities/chat.dart';

abstract interface class ChatsRepository {
  Future<Either<String, String>> onAddChat({required String nickname});

  Stream<List<Chat>> getChatsStream();
  Stream<int> getUnreadCountStream({
    required String chatId,
    required String userId,
  });
  void updateLastMessage({
    required String chatId,
    required String? compareWithMessage,
    required String? compareWithMessageId,
  });
}
