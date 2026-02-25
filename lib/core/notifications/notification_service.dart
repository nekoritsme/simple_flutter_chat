import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:simple_flutter_chat/core/logger.dart';

class NotificationService {
  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    talker.info('Notification permission: ${settings.authorizationStatus}');

    final token = await messaging.getToken();
    talker.info("FCM token: $token");
  }

  Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken();
  }

  void startTokenRefreshListener({
    required Future<void> Function(String token) onTokenRefresh,
  }) {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen(
          (token) async {
            talker.info("FCM token refreshed: $token");
            await onTokenRefresh(token);
          },
          onError: (Object err, StackTrace stackTrace) {
            talker.error(err, stackTrace);
          },
        );
  }

  Future<void> stopTokenRefreshListener() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }
}
