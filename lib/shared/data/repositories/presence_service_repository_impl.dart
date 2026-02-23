import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_flutter_chat/shared/domain/entities/activity.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/presence_service_repository.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/user_repository.dart';

class PresenceServiceRepositoryImpl implements PresenceServiceRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRep;

  PresenceServiceRepositoryImpl({
    required FirebaseFirestore firestore,
    required UserRepository userRep,
  }) : _firestore = firestore,
       _userRep = userRep;

  @override
  Stream<ActivityStatus> getStatusStreamByUserId({required String userId}) {
    return _firestore.collection("users").doc(userId).snapshots().map((
      documentSnapshot,
    ) {
      final data = documentSnapshot.data();
      if (data == null) {
        return ActivityStatus(isOnline: false, lastSeen: DateTime.now());
      }

      final isOnline = data["isOnline"];
      final lastSeenRaw = data["lastSeenOnline"] as Timestamp;
      final lastSeen = lastSeenRaw.toDate();

      return ActivityStatus(isOnline: isOnline, lastSeen: lastSeen);
    });
  }

  @override
  Future<void> setOffline() async {
    await _firestore.collection("users").doc(_userRep.currentUser.id).update({
      "isOnline": false,
      "lastSeenOnline": FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setOnline() async {
    await _firestore.collection("users").doc(_userRep.currentUser.id).update({
      "isOnline": true,
      "lastSeenOnline": FieldValue.serverTimestamp(),
    });
  }
}
