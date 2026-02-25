abstract interface class NotificationTokenSyncRepository {
  Future<void> syncCurrentToken();
  void startTokenRefreshSync();
  Future<void> stopTokenRefreshSync();
  Future<void> removeCurrentToken();
}
