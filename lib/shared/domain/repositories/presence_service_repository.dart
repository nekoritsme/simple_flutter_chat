import 'package:dart_either/dart_either.dart';

abstract interface class PresenceServiceRepository {
  Future<Either<String, Map<String, dynamic>>> getStatusByUserId({
    required String userId,
  });
  Future<void> setOnline();
  Future<void> setOffline();
}
