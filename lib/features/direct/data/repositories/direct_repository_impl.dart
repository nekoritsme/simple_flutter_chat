import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/dart_either.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_flutter_chat/core/extensions/timestamp_extensions.dart';
import 'package:simple_flutter_chat/core/logger.dart';
import 'package:simple_flutter_chat/features/direct/domain/repositories/direct_messages_controller_repository.dart';
import 'package:simple_flutter_chat/shared/domain/repositories/user_repository.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/Message.dart';
import '../../domain/repositories/direct_repository.dart';

class DirectRepositoryImpl implements DirectRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepo;
  final FirebaseStorage _firebaseStorage;
  final DirectMessagesControllerRepository _directMessagesControllerRepository;

  DirectRepositoryImpl({
    required FirebaseFirestore firestore,
    required UserRepository userRepo,
    required FirebaseStorage firebaseStorage,
    required DirectMessagesControllerRepository
    directMessagesControllerRepository,
  }) : _firestore = firestore,
       _userRepo = userRepo,
       _firebaseStorage = firebaseStorage,
       _directMessagesControllerRepository = directMessagesControllerRepository;

  @override
  Future<Either<String, List<String>>> getParticipants({
    required String chatId,
  }) async {
    try {
      final participantsRaw =
          (await _firestore.collection("chats").doc(chatId).get()).get(
            "participants",
          );

      final participants = (participantsRaw as List)
          .whereType<String>()
          .toList();

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

            final String? profileUrl = messageData["profileUrl"];

            return Message(
              createdAt:
                  (messageData["createdAt"] as Timestamp).toDateTime ??
                  DateTime.now(),
              nickname: messageData["nickname"] ?? "Error nickname",
              text: messageData["text"] ?? "Error text",
              userId: messageData["userId"] ?? "Error id",
              messageId: "Message id", // doesn't matter ig
              editedAt: messageData["editedAt"],
              profileUrl: profileUrl,
            );
          }

          return null;
        });
  }

  @override
  Future<Either<String, String>> submitMessage({
    required String chatId,
    required String message,
    required String? replyMessageId,
    required String? replyMessage,
  }) async {
    try {
      final userData = await _firestore
          .collection("users")
          .doc(_userRepo.currentUser.id)
          .get();

      final String? profileUrl = userData.data()!["profileUrl"];

      await _firestore.collection("chats/$chatId/messages").add({
        "text": message,
        "createdAt": FieldValue.serverTimestamp(),
        "userId": _userRepo.currentUser.id,
        "nickname": userData.data()!["nickname"],
        "profileUrl": profileUrl,
        "replyMessageId": replyMessageId,
        "replyMessage": replyMessage,
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

  @override
  Future<Either<String, String>> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      final messagesRef = _firestore.collection("chats/$chatId/messages");

      var lastMessageQuery = await messagesRef
          .orderBy("createdAt", descending: true)
          .limit(1)
          .get();

      bool isLastMessage = false;
      if (lastMessageQuery.docs.isNotEmpty) {
        isLastMessage = lastMessageQuery.docs.first.id == messageId;
      }

      await messagesRef.doc(messageId).delete();
      _directMessagesControllerRepository.removeMessage(messageId: messageId);

      if (isLastMessage) {
        lastMessageQuery = await messagesRef
            .orderBy("createdAt", descending: true)
            .limit(1)
            .get();

        if (lastMessageQuery.docs.isNotEmpty) {
          await _firestore.collection("chats").doc(chatId).update({
            "lastMessage": lastMessageQuery.docs.first.get("text"),
            "lastMessageTimestamp": lastMessageQuery.docs.first.get(
              "createdAt",
            ),
            "lastMessageSenderId": lastMessageQuery.docs.first.get("userId"),
          });
        } else {
          await _firestore.collection("chats").doc(chatId).update({
            "lastMessage": null,
            "lastMessageTimestamp": null,
            "lastMessageSenderId": null,
          });
        }
      }

      return Right("Success");
    } catch (err, stack) {
      talker.error(err, stack);
      return Left("Failure");
    }
  }

  @override
  Future<Either<String, String>> sendImage({
    required String chatId,
    required String? replyMessageId,
    required String? replyMessage,
  }) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) {
      return Left("No image selected");
    }

    final uuid = Uuid();

    final storageImage = _firebaseStorage
        .ref()
        .child(chatId)
        .child("${uuid.v4()}.jpg");

    await storageImage.putFile(File(pickedImage.path));
    final downloadUrl = await storageImage.getDownloadURL();

    talker.info(downloadUrl);
    try {
      final userData = await _firestore
          .collection("users")
          .doc(_userRepo.currentUser.id)
          .get();

      final String? profileUrl = userData.data()!["profileUrl"];

      await _firestore.collection("chats/$chatId/messages").add({
        "text": "",
        "createdAt": FieldValue.serverTimestamp(),
        "userId": _userRepo.currentUser.id,
        "nickname": userData.data()!["nickname"],
        "profileUrl": profileUrl,
        "replyMessageId": replyMessageId,
        "replyMessage": replyMessage,
        "imageDownloadUrl": downloadUrl,
      });

      return Right("Success");
    } catch (err, stack) {
      talker.error(err, stack);
      return Left("Failure while submitting message");
    }
  }
}
