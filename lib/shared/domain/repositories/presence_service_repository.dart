import '../entities/activity.dart';

abstract interface class PresenceServiceRepository {
  Stream<ActivityStatus> getStatusStreamByUserId({required String userId});
  Future<void> setOnline();
  Future<void> setOffline();
}
