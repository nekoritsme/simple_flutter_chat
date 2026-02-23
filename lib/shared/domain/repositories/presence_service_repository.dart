abstract interface class PresenceServiceRepository {
  Future<void> setOnline();
  Future<void> setOffline();
}
