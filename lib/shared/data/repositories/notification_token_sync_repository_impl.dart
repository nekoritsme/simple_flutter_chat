import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_flutter_chat/core/notifications/notification_service.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/notification_token_sync_repository.dart';

class NotificationTokenSyncRepositoryImpl
    implements NotificationTokenSyncRepository {
  NotificationTokenSyncRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
    required NotificationService notificationService,
  }) : _firebaseAuth = firebaseAuth,
       _firebaseFirestore = firebaseFirestore,
       _notificationService = notificationService;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final NotificationService _notificationService;

  @override
  Future<void> syncCurrentToken() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    final token = await _notificationService.getToken();
    if (token == null || token.isEmpty) return;

    await _firebaseFirestore.collection("users").doc(currentUser.uid).set({
      "fcmTokens": FieldValue.arrayUnion([token]),
      "fcmToken": token,
    }, SetOptions(merge: true));
  }

  @override
  void startTokenRefreshSync() {
    _notificationService.startTokenRefreshListener(
      onTokenRefresh: (token) async {
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser == null) return;

        await _firebaseFirestore.collection("users").doc(currentUser.uid).set({
          "fcmTokens": FieldValue.arrayUnion([token]),
          "fcmToken": token,
        }, SetOptions(merge: true));
      },
    );
  }

  @override
  Future<void> stopTokenRefreshSync() async {
    await _notificationService.stopTokenRefreshListener();
  }

  @override
  Future<void> removeCurrentToken() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    final token = await _notificationService.getToken();
    if (token == null || token.isEmpty) return;

    await _firebaseFirestore.collection("users").doc(currentUser.uid).set({
      "fcmTokens": FieldValue.arrayRemove([token]),
    }, SetOptions(merge: true));
  }
}
