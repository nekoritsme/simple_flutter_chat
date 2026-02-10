import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = false;

  final bool isFirstInSequence;
  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          child: Row(
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
                            color: theme.colorScheme.onPrimary.withAlpha(100),
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
        ),
      ],
    );
  }
}
