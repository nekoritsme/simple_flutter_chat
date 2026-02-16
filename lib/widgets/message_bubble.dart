import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:link_text/link_text.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.message,
    required this.isMe,
    required this.createdAt,
    required this.isRead,
    this.isEdited,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.createdAt,
    required this.isRead,
    this.isEdited,
  }) : isFirstInSequence = false;

  final bool isFirstInSequence;
  final String message;
  final bool isMe;
  final Timestamp createdAt;
  final bool isRead;
  final bool? isEdited;

  String _formatMessageTime(Timestamp createdAt) {
    final date = createdAt.toDate();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formatMessageTime = _formatMessageTime(createdAt);

    return Stack(
      children: [
        if (isFirstInSequence)
          Positioned(
            bottom: 0,
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/profile-picture-holder.jpg",
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(right: isMe ? 30 : 0, left: !isMe ? 30 : 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12).copyWith(
                        bottomRight: isFirstInSequence
                            ? isMe
                                  ? Radius.zero
                                  : Radius.circular(12)
                            : null,
                        bottomLeft: isFirstInSequence
                            ? isMe
                                  ? Radius.circular(12)
                                  : Radius.zero
                            : null,
                      ),
                      color: isMe
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      boxShadow: isMe
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.onPrimary.withAlpha(
                                  100,
                                ),
                                blurRadius: 30,
                                spreadRadius: -8,
                              ),
                            ]
                          : null,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: LinkText(
                        message,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                        linkStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                        ),
                        onLinkTap: (url) {
                          launchUrl(Uri.parse(url));
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isEdited != null && isEdited! && isMe) ...[
                      Text(
                        "Edited",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      formatMessageTime,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 5),
                      Icon(
                        Icons.done_all,
                        color: isRead
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                    if (isEdited != null && isEdited! && !isMe) ...[
                      const SizedBox(width: 5),
                      Text(
                        "Edited",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
