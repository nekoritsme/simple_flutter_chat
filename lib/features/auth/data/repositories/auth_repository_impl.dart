import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/src/dart_either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_flutter_chat/core/logger.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseAuth = firebaseAuth,
       _firebaseFirestore = firebaseFirestore;

  @override
  Future<Either> handleLogin({
    required String email,
    required String password,
  }) async {
    try {
      final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      talker.info("User has been logged in: $userCredentials");
      return Right("Success");
    } catch (err, stacktrace) {
      talker.error(err, stacktrace);
      return Left("Login failure, try again later.");
    }
  }

  @override
  Future<Either> handleSignUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final userCredentials = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firebaseFirestore
          .collection("users")
          .doc(userCredentials.user!.uid)
          .set({
            "nickname": nickname,
            "email": email,
            "createdAt": Timestamp.now(),
          });
      talker.info("User has been registered: $userCredentials");

      return Right("Success");
    } on FirebaseAuthException catch (err) {
      talker.error(err);
      return Left("Sign up failure, try again later.");
    }
  }
}
