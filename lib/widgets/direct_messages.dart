import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/widgets/message_bubble.dart';

class DirectMessagesWidget extends StatelessWidget {
  const DirectMessagesWidget({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chats/$chatId/messages")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (ctx, messagesSnapshots) {
        if (messagesSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!messagesSnapshots.hasData ||
            messagesSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text("No messages was found"));
        }

        if (messagesSnapshots.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        final loadedMessages = messagesSnapshots.data!.docs;

        return ListView.separated(
          itemCount: loadedMessages.length,
          reverse: false,
          itemBuilder: (contx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final isMe = chatMessage["userId"] == authenticatedUser!.uid;

            final currentUserId = chatMessage["userId"];
            final nextUserId = nextChatMessage != null
                ? nextChatMessage["userId"]
                : null;

            if (currentUserId == nextUserId) {
              return MessageBubble.next(
                message: chatMessage["text"],
                isMe: isMe,
              );
            }

            return MessageBubble.first(
              message: chatMessage["text"],
              isMe: isMe,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 10);
          },
        );
      },
    );
  }
}
