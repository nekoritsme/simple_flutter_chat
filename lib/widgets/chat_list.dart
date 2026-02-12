import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/widgets/chat_item.dart';
import 'package:talker_flutter/talker_flutter.dart';

class ChatListWidget extends StatelessWidget {
  ChatListWidget({super.key});

  final user = FirebaseAuth.instance.currentUser;
  final talker = Talker();

  Stream<int> _getUnreadCount(String chatId, String userId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .asyncMap((chatDoc) async {
          final lastRead =
              chatDoc.data()?['lastReadTimestamp'][userId] as Timestamp?;

          if (lastRead == null) {
            final allMessages = await FirebaseFirestore.instance
                .collection('chats/$chatId/messages')
                .where('userId', isNotEqualTo: userId)
                .count()
                .get();
            return allMessages.count ?? 0;
          }

          final unreadMessages = await FirebaseFirestore.instance
              .collection('chats/$chatId/messages')
              .where('userId', isNotEqualTo: userId)
              .where('createdAt', isGreaterThan: lastRead)
              .count()
              .get();

          return unreadMessages.count ?? 0;
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .where("participants", arrayContains: user!.uid)
          .orderBy("lastMessageTimestamp", descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text("No chats found"));
        }

        if (chatSnapshots.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        final loadedChats = chatSnapshots.data!.docs;

        return ListView.builder(
          itemCount: loadedChats.length,
          itemBuilder: (ctx, index) {
            final participants = List<String>.from(
              loadedChats[index]['participants'] ?? const [],
            );
            final otherUser = participants.firstWhere(
              (id) => id != user!.uid,
              orElse: () => '',
            );

            if (otherUser.isEmpty) {
              return ChatItemWidget(
                chatNickname: "Invalid chat",
                lastMessage: "",
                lastMessageTimestamp: Timestamp(0, 0),
                unreadCount: 0,
                chatId: loadedChats[index].id,
              );
            }

            return StreamBuilder(
              key: ValueKey(loadedChats[index].id),
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(otherUser)
                  .snapshots(),
              builder: (contx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ChatItemWidget(
                    chatNickname: "Loading...",
                    lastMessage: "",
                    lastMessageTimestamp: Timestamp(0, 0),
                    unreadCount: 0,
                    chatId: "wait",
                  );
                }

                if (snapshot.hasError) {
                  return ChatItemWidget(
                    chatNickname: "Error loading user",
                    lastMessage: "",
                    lastMessageTimestamp: Timestamp(0, 0),
                    unreadCount: 0,
                    chatId: "error",
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return ChatItemWidget(
                    chatNickname: "User not found",
                    lastMessage: "",
                    lastMessageTimestamp: Timestamp(0, 0),
                    unreadCount: 0,
                    chatId: "not found",
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final nickname = userData["nickname"] ?? "Unknown";

                var time = loadedChats[index]["lastMessageTimestamp"];

                time == null ? time = null : time.toDate().toString();

                return StreamBuilder(
                  stream: _getUnreadCount(loadedChats[index].id, user!.uid),
                  builder: (context, unreadSnapshot) {
                    final unreadCount = unreadSnapshot.data ?? 0;

                    talker.info("Unread counter: $unreadCount");

                    return ChatItemWidget(
                      chatNickname: nickname,
                      lastMessage: loadedChats[index]["lastMessage"],
                      lastMessageTimestamp: time,
                      unreadCount: unreadCount,
                      chatId: loadedChats[index].id,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
