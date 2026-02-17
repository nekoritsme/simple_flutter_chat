import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/features/chats/domain/repositories/chats_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class AddChatUseCase {
  Future<Either<String, String>> onAddChat(String nickname) async {
    return await sl<ChatsRepository>().onAddChat(nickname);
  }
}
