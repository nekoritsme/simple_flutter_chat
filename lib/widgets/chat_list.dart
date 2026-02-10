import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/widgets/chat_item.dart';

class ChatListWidget extends StatelessWidget {
  ChatListWidget({super.key});

  final user = FirebaseAuth.instance.currentUser;

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
            final otherUser = loadedChats[index]['participants'].firstWhere(
              (id) => id != user!.uid,
            );

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
                    lastMessageTimestamp: "",
                    unreadCount: 0,
                    chatId: "wait",
                  );
                }

                if (snapshot.hasError) {
                  return ChatItemWidget(
                    chatNickname: "Error loading user",
                    lastMessage: "",
                    lastMessageTimestamp: "",
                    unreadCount: 0,
                    chatId: "error",
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return ChatItemWidget(
                    chatNickname: "User not found",
                    lastMessage: "",
                    lastMessageTimestamp: "",
                    unreadCount: 0,
                    chatId: "not found",
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final nickname = userData["nickname"] ?? "Unknown";

                var time = loadedChats[index]["lastMessageTimestamp"];

                time == null ? time = "" : time.toDate().toString();

                return ChatItemWidget(
                  chatNickname: nickname,
                  lastMessage: loadedChats[index]["lastMessage"],
                  lastMessageTimestamp: time,
                  unreadCount: loadedChats[index]["unreadCount"][user!.uid],
                  chatId: loadedChats[index].id,
                );
              },
            );
          },
        );
      },
    );
  }
}
