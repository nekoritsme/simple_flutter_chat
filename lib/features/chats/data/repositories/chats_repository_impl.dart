import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_either/src/dart_either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_flutter_chat/features/chats/domain/repositories/chats_repository.dart';

import '../../../../core/logger.dart';
import '../../domain/entities/chat.dart';

class ChatsRepositoryImpl implements ChatsRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  ChatsRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseAuth = firebaseAuth,
       _firebaseFirestore = firebaseFirestore;

  @override
  Future<Either<String, String>> onAddChat(String nickname) async {
    final trimmedNickname = nickname.trim();

    String generateChatId(String userId1, String userId2) {
      final List<String> ids = [userId1, userId2]..sort();

      return ids.join('_');
    }

    try {
      final user = await _firebaseFirestore
          .collection("users")
          .where("nickname", isEqualTo: trimmedNickname)
          .get();

      final bool isUserExists = user.docs.isNotEmpty;
      if (!isUserExists) return Left("User doesn't exists");

      final currentUser = _firebaseAuth.currentUser!.uid;
      final otherUser = user.docs.first.id;

      final chatId = generateChatId(currentUser, otherUser);
      final chatDoc = await _firebaseFirestore
          .collection("chats")
          .doc(chatId)
          .get();

      if (chatDoc.exists) return Left("Chat already exists");

      await _firebaseFirestore.collection("chats").doc(chatId).set({
        "participants": [currentUser, otherUser],
        "createdAt": FieldValue.serverTimestamp(),
        "lastMessage": null,
        "lastMessageTimestamp": null,
        "lastMessageSenderId": null,
        "lastReadTimestamp": {
          currentUser: FieldValue.serverTimestamp(),
          otherUser: FieldValue.serverTimestamp(),
        },
      });

      talker.info("Chat has been created");

      return Right("Chat has been added");
    } catch (err) {
      talker.error(err);
      return Left("Something went wrong");
    }
  }

  @override
  Stream<List<Chat>> getChatsStream() {
    return _firebaseFirestore
        .collection("chats")
        .where("participants", arrayContains: _firebaseAuth.currentUser!.uid)
        .orderBy("lastMessageTimestamp", descending: true)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs.map((doc) {
            final data = doc.data();

            final lastMessageTimestamp =
                (data['lastMessageTimestamp'] as Timestamp?)?.toDate();
            final lastReadTimestampRaw =
                data['lastReadTimestamp'] as Map<String, dynamic>?;

            Map<String, DateTime> lastReadTimestamp = {};
            if (lastReadTimestampRaw != null) {
              lastReadTimestampRaw.forEach((key, value) {
                if (value is Timestamp) {
                  lastReadTimestamp[key] = value.toDate();
                }
              });
            }

            return Chat(
              id: doc.id,
              lastMessage: data['lastMessage'] ?? '',
              lastMessageSenderId: data['lastMessageSenderId'] ?? '',
              lastMessageTimestamp: lastMessageTimestamp ?? DateTime.now(),
              lastReadTimestamp: lastReadTimestamp,
              participants: List<String>.from(data['participants'] ?? []),
            );
          }).toList();
        });
  }

  @override
  Stream<int> getUnreadCountStream(String chatId, String userId) {
    return _firebaseFirestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .asyncMap((chatDoc) async {
          final lastRead =
              chatDoc.data()?['lastReadTimestamp'][userId] as Timestamp?;

          if (lastRead == null) {
            final allMessages = await _firebaseFirestore
                .collection('chats/$chatId/messages')
                .where('userId', isNotEqualTo: userId)
                .count()
                .get();
            return allMessages.count ?? 0;
          }

          final unreadMessages = await _firebaseFirestore
              .collection('chats/$chatId/messages')
              .where('userId', isNotEqualTo: userId)
              .where('createdAt', isGreaterThan: lastRead)
              .count()
              .get();

          return unreadMessages.count ?? 0;
        });
  }

  @override
  void updateLastMessage(
    String chatId,
    String? compareWithMessage,
    String? compareWithMessageId,
  ) async {
    final messagesRef = _firebaseFirestore.collection("chats/$chatId/messages");

    var lastMessageQuery = await messagesRef
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    bool isLastMessage = false;
    if (lastMessageQuery.docs.isNotEmpty) {
      isLastMessage = lastMessageQuery.docs.first.id == compareWithMessageId;
    }

    if (isLastMessage || compareWithMessage == null) {
      lastMessageQuery = await messagesRef
          .orderBy("createdAt", descending: true)
          .limit(1)
          .get();

      if (lastMessageQuery.docs.isNotEmpty) {
        await _firebaseFirestore.collection("chats").doc(chatId).update({
          "lastMessage": lastMessageQuery.docs.first.get("text"),
          "lastMessageTimestamp": lastMessageQuery.docs.first.get("createdAt"),
        });
      } else {
        await FirebaseFirestore.instance.collection("chats").doc(chatId).update(
          {"lastMessage": null, "lastMessageTimestamp": null},
        );
      }
    }
  }
}
