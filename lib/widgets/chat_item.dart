import 'package:flutter/material.dart';

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
  final String lastMessageTimestamp;
  final int unreadCount;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          children: [
            Text(lastMessageTimestamp),
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
