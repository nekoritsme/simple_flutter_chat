import 'package:simple_flutter_chat/features/chats/domain/repositories/chats_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class GetUnreadCountStreamUseCase {
  Stream<int> getUnreadCountStream({
    required String chatId,
    required String userId,
  }) {
    return sl<ChatsRepository>().getUnreadCountStream(
      chatId: chatId,
      userId: userId,
    );
  }
}
