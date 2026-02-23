import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<Map<String, dynamic>> get getStatus async {
    final doc = await _firestore
        .collection("users")
        .doc(_userRep.currentUser.id)
        .get();

    if (!doc.exists || doc.data()!.isEmpty) {
      throw Exception("User must be found, but its not or it's empty");
    }

    final data = doc.data()!;
    return {
      "isOnline": data["isOnline"],
      "lastSeenOnline": (data["lastSeenOnline"] as Timestamp).toDate(),
    };
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
