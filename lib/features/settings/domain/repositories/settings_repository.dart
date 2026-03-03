import 'package:dart_either/dart_either.dart';

abstract interface class SettingsRepository {
  Future<Either<String, String>> pickImage();
}
