import 'package:simple_flutter_chat/features/chats/domain/entities/chat.dart';
import 'package:simple_flutter_chat/features/chats/domain/repositories/chats_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class GetChatsStreamsUseCase {
  Stream<List<Chat>> getChatsStream() {
    return sl<ChatsRepository>().getChatsStream();
  }
}
