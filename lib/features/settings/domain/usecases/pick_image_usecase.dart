import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/features/settings/domain/repositories/settings_repository.dart';

import '../../../../service_locator.dart';

class PickImageUseCase {
  Future<Either<String, String>> pickImageAndUpload() {
    return sl<SettingsRepository>().pickImage();
  }
}
