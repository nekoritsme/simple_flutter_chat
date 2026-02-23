import 'package:simple_flutter_chat/service_locator.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/presence_service_repository.dart';

class SetOfflineUseCase {
  void setOffline() {
    sl<PresenceServiceRepository>().setOffline();
  }
}
