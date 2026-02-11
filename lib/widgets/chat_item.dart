import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screens/direct.dart';

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget({
    super.key,
    required this.chatNickname,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.unreadCount,
    required this.chatId,
  });

  final String chatNickname;
  final String? lastMessage;
  final Timestamp lastMessageTimestamp;
  final int unreadCount;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessageTime = DateFormat(
      "hh:mm",
    ).format(lastMessageTimestamp.toDate());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => DirectMessagesScreen(
              chatId: chatId,
              chatNickname: chatNickname,
            ),
          ),
        );
      },
      child: ListTile(
        title: Text(
          chatNickname,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          lastMessage ?? "",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: unreadCount > 0 ? theme.colorScheme.primary : null,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              lastMessageTime,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: unreadCount > 0 ? theme.colorScheme.primary : null,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            if (unreadCount > 0)
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.onPrimary.withAlpha(100),
                      offset: Offset(-8, 0),
                      blurRadius: 30,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                width: 25,
                height: 25,
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    unreadCount.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            if (unreadCount == 0)
              Icon(Icons.done_all, color: theme.colorScheme.primary),
            // const SizedBox(height: 5),
            // const Text("3"),
            //
            // if (unreadCount > 0) Text(unreadCount.toString()),
          ],
        ),
        leading: CircleAvatar(
          backgroundImage: AssetImage(
            "assets/images/profile-picture-holder.jpg",
          ),
        ),
      ),
    );
  }
}
