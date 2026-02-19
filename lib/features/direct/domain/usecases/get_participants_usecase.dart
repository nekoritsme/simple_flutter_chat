import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/features/direct/domain/presentation/direct_repository.dart';
import 'package:simple_flutter_chat/service_locator.dart';

class GetParticipantsUseCase {
  Future<Either<String, List<String>>> getParticipants(String chatId) async {
    return await sl<DirectRepository>().getParticipants(chatId);
  }
}
