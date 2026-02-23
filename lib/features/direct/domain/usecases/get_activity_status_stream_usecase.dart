import 'package:simple_flutter_chat/service_locator.dart';
import 'package:simple_flutter_chat/shared/domain/entities/activity.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/presence_service_repository.dart';

class GetActivityStatusStreamUseCase {
  Stream<ActivityStatus> getActivityStatusStream({required String userId}) {
    return sl<PresenceServiceRepository>().getStatusStreamByUserId(
      userId: userId,
    );
  }
}
