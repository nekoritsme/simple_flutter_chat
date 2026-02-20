import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_flutter_chat/core/logger.dart';
import 'package:simple_flutter_chat/shared/domain/entities/user.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  UserRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseAuth = firebaseAuth,
       _firebaseFirestore = firebaseFirestore;

  @override
  Future<String> get nickname async {
    try {
      final user = _firebaseAuth.currentUser;

      final currentUserNickname = await _firebaseFirestore
          .collection("users")
          .doc(user!.uid)
          .get();

      return currentUserNickname["nickname"];
    } catch (err, stackTrace) {
      talker.error(err, stackTrace);
      rethrow;
    }
  }

  @override
  UserEntity get currentUser {
    final user = _firebaseAuth.currentUser;

    return UserEntity(id: user!.uid);
  }

  @override
  Stream<UserEntity> specificUserStream({required String uid}) {
    return _firebaseFirestore.collection("users").doc(uid).snapshots().map((
      documentSnapshot,
    ) {
      final data = documentSnapshot.data();
      if (data == null) {
        throw Exception("User document not found");
      }
      return UserEntity(
        id: documentSnapshot.id,
        nickname: data["nickname"] ?? "",
      );
    });
  }
}
