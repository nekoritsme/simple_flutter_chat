import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/features/chats/domain/entities/chat.dart';

abstract interface class ChatsRepository {
  Future<Either<String, String>> onAddChat(String nickname);

  Stream<List<Chat>> getChatsStream();
  Stream<int> getUnreadCountStream(String chatId, String userId);
  void updateLastMessage(
    String chatId,
    String? compareWithMessage,
    String? compareWithMessageId,
  );
}
