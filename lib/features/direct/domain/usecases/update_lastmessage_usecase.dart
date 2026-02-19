import 'package:simple_flutter_chat/features/chats/domain/repositories/chats_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class UpdateLastMessageUseCase {
  void updateLastMessage(
    String chatId,
    String? compareWithMessage,
    String? compareWithMessageId,
  ) {
    sl<ChatsRepository>().updateLastMessage(
      chatId,
      compareWithMessage,
      compareWithMessageId,
    );
  }
}
