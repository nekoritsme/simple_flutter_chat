import 'package:simple_flutter_chat/service_locator.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/notification_token_sync_repository.dart';

class StopNotificationTokenSyncUseCase {
  Future<void> stop() async {
    await sl<NotificationTokenSyncRepository>().stopTokenRefreshSync();
  }
}
