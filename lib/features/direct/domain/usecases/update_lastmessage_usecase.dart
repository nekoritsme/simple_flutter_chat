import 'package:simple_flutter_chat/features/chats/domain/repositories/chats_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class UpdateLastMessageUseCase {
  void updateLastMessage({
    required String chatId,
    required String? compareWithMessage,
    required String? compareWithMessageId,
  }) {
    sl<ChatsRepository>().updateLastMessage(
      chatId: chatId,
      compareWithMessage: compareWithMessage,
      compareWithMessageId: compareWithMessageId,
    );
  }
}
