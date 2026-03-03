import 'package:dart_either/src/dart_either.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<Either<String, String>> pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 200,
    );

    if (pickedImage == null) {
      return Left("No image selected");
    }

    throw UnimplementedError();
  }
}
