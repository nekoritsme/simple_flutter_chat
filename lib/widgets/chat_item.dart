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
    this.isMe,
    this.isRead,
  });

  final String chatNickname;
  final String? lastMessage;
  final Timestamp? lastMessageTimestamp;
  final int unreadCount;
  final String chatId;
  final bool? isRead;
  final bool? isMe;

  String _formatChatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";

    final DateTime messageTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(messageTime);

    if (difference.inHours < 24 && messageTime.day == now.day) {
      return DateFormat('HH:mm').format(messageTime);
    }

    final DateTime yesterday = now.subtract(Duration(days: 1));
    if (messageTime.day == yesterday.day &&
        messageTime.month == yesterday.month &&
        messageTime.year == yesterday.year) {
      return 'Yesterday';
    }

    if (difference.inDays >= 1 && difference.inDays <= 8) {
      return DateFormat('EEEE').format(messageTime);
    }

    if (difference.inDays >= 9 && difference.inDays <= 29) {
      return '${difference.inDays} days ago';
    }

    return DateFormat('dd/MM/yyyy').format(messageTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessageTime = _formatChatTimestamp(lastMessageTimestamp);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            barrierColor: Color.fromARGB(255, 16, 28, 34),
            pageBuilder: (ctx, animation, secondaryAnimation) =>
                DirectMessagesScreen(
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
            fontFamilyFallback: const [
              'Roboto',
              'Apple Color Emoji',
              'Noto Color Emoji',
              'Segoe UI Emoji',
            ],
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
                    unreadCount >= 99 ? 99.toString() : unreadCount.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            if (unreadCount == 0 &&
                lastMessageTimestamp != null &&
                (isMe ?? false))
              Icon(
                Icons.done_all,
                color: isRead != null && isRead!
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
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
