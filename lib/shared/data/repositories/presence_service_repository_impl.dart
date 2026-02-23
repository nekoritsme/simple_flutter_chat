import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/core/logger.dart';
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
  Future<Either<String, Map<String, dynamic>>> getStatusByUserId({
    required String userId,
  }) async {
    try {
      final doc = await _firestore.collection("users").doc(userId).get();

      if (!doc.exists || doc.data()!.isEmpty) {
        return Left("User wasn't be found or it's empty");
      }

      final data = doc.data()!;

      return Right({
        "isOnline": data["isOnline"],
        "lastSeenOnline": (data["lastSeenOnline"] as Timestamp).toDate(),
      });
    } catch (err, stack) {
      talker.error(err, stack);
      return Left("Unexpected presence service error");
    }
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
