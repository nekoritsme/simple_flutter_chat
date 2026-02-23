import 'package:simple_flutter_chat/features/direct/domain/entities/Message.dart';
import 'package:simple_flutter_chat/features/direct/domain/repositories/direct_messages_controller_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class GetMessagesStreamUseCase {
  Stream<List<Message>> getMessagesStream() {
    return sl<DirectMessagesControllerRepository>().messageStream;
  }
}
