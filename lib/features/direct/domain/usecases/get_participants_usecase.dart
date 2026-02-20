import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/service_locator.dart';

import '../repositories/direct_repository.dart';

class GetParticipantsUseCase {
  Future<Either<String, List<String>>> getParticipants(String chatId) async {
    return await sl<DirectRepository>().getParticipants(chatId);
  }
}
