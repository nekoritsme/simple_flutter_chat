import 'package:simple_flutter_chat/service_locator.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/presence_service_repository.dart';

class SetOnlineUseCase {
  void setOnline() {
    sl<PresenceServiceRepository>().setOnline();
  }
}
