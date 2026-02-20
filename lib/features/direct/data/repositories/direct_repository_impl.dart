import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/dart_either.dart';
import 'package:simple_flutter_chat/core/extensions/timestamp_extensions.dart';
import 'package:simple_flutter_chat/core/logger.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/user_repository.dart';

import '../../domain/entities/Message.dart';
import '../../domain/repositories/direct_repository.dart';

class DirectRepositoryImpl implements DirectRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepo;

  DirectRepositoryImpl({
    required FirebaseFirestore firestore,
    required UserRepository userRepo,
  }) : _firestore = firestore,
       _userRepo = userRepo;

  @override
  Future<Either<String, List<String>>> getParticipants({
    required String chatId,
  }) async {
    try {
      final participants =
          (await _firestore.collection("chats").doc(chatId).get()).get(
            "participants",
          );

      return Right(participants);
    } catch (err, stack) {
      talker.error(err, stack);
      return Left(err.toString());
    }
  }

  @override
  Future<Either<String, String>> updateLastReadTimestamp({
    required String chatId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatId).update({
        "lastReadTimestamp.${_userRepo.currentUser.id}":
            FieldValue.serverTimestamp(),
      });

      return Right("Last read timestamp updated");
    } catch (err, stack) {
      talker.error(err, stack);
      return Left("Error while updating last read timestamp");
    }
  }

  @override
  Stream<Message?> getLastMessageStream({required String chatId}) {
    return _firestore
        .collection("chats/$chatId/messages")
        .orderBy("createdAt", descending: false)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final messageData = snapshot.docs.first.data();

            return Message(
              createdAt:
                  (messageData["createdAt"] as Timestamp).toDateTime ??
                  DateTime.now(),
              nickname: messageData["nickname"] ?? "Error nickname",
              text: messageData["text"] ?? "Error text",
              messageId: messageData["userId"] ?? "Error id",
            );
          }

          return null;
        });
  }

  @override
  Future<Either<String, String>> submitMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      final userData = await _firestore
          .collection("users")
          .doc(_userRepo.currentUser.id)
          .get();

      await _firestore.collection("chats/$chatId/messages").add({
        "text": message,
        "createdAt": FieldValue.serverTimestamp(),
        "userId": _userRepo.currentUser.id,
        "nickname": userData.data()!["nickname"],
      });

      return Right("Success");
    } catch (err, stack) {
      talker.error(err, stack);
      return Left("Failure while submitting message");
    }
  }

  @override
  Future<Either<String, String>> editMessage({
    required String chatId,
    required String messageId,
    required String newMessage,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("chats/$chatId/messages")
          .doc(messageId)
          .update({
            "text": newMessage,
            "editedAt": FieldValue.serverTimestamp(),
          });

      return Right("Success");
    } catch (err, stack) {
      talker.error(err, stack);
      return Left("Failure");
    }
  }
}
