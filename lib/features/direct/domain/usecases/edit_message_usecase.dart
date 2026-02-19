import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/features/direct/domain/presentation/direct_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class EditMessageUseCase {
  Future<Either<String, String>> editMessage(
    String chatId,
    String messageId,
    String newMessage,
  ) async {
    return sl<DirectRepository>().editMessage(chatId, messageId, newMessage);
  }
}
