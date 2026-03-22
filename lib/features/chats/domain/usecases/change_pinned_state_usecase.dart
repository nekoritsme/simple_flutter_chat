import '../../../../service_locator.dart';
import '../repositories/chats_repository.dart';

class ChangePinnedStateUseCase {
  Future<void> call({required String chatId, required bool isPinned}) {
    return sl<ChatsRepository>().pinChat(chatId: chatId, isPinned: isPinned);
  }
}
