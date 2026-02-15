import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.message,
    required this.isMe,
    required this.createdAt,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.createdAt,
  }) : isFirstInSequence = false;

  final bool isFirstInSequence;
  final String message;
  final bool isMe;
  final Timestamp createdAt;

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
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                        softWrap: true,
                        maxLines: null,
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
                    Text(
                      formatMessageTime,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                    if (isMe)
                      Icon(
                        Icons
                            .done_all, // TODO: change color depending on the read state
                        color: theme.colorScheme.onSurfaceVariant,
                      ), // placeholder till done
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
