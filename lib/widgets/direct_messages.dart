import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_flutter_chat/widgets/message_bubble.dart';
import 'package:vibration/vibration.dart';

class DirectMessagesWidget extends StatefulWidget {
  const DirectMessagesWidget({
    super.key,
    required this.chatId,
    required this.editMessage,
    required this.otherUserId,
  });

  final Function({
    required String messageId,
    required Map<String, dynamic> message,
  })
  editMessage;

  final String chatId;
  final String otherUserId;

  @override
  State<DirectMessagesWidget> createState() => _DirectMessagesWidgetState();
}

class _DirectMessagesWidgetState extends State<DirectMessagesWidget> {
  final _scrollController = ScrollController();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream;

  Stream<dynamic> get _otherUserLastReadStream {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .snapshots()
        .map((docSnapshot) {
          final data = docSnapshot.data();
          return data?['lastReadTimestamp']?[widget.otherUserId];
        })
        .distinct();
  }

  Future<void> _showMessageMenu({
    required Offset globalPosition,
    required String messageId,
    required Map<String, dynamic> message,
    required bool isMe,
  }) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    const horizontalPadding = 8;
    const estimatedMenuWidth = 180.0;
    final safeY = globalPosition.dy.clamp(8, overlay.size.height - 8);
    final safeX = (globalPosition.dx - estimatedMenuWidth).clamp(
      horizontalPadding,
      overlay.size.width - horizontalPadding,
    );
    final leftAnchoredPoint = Offset(safeX.toDouble(), safeY.toDouble());
    final position = RelativeRect.fromRect(
      Rect.fromPoints(leftAnchoredPoint, leftAnchoredPoint),
      Offset.zero & overlay.size,
    );

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }

    final selectedAction = await showMenu<String>(
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      surfaceTintColor: Theme.of(context).colorScheme.onSurface,
      color: Theme.of(context).colorScheme.onSurface,
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.bounceOut,
        duration: const Duration(milliseconds: 0),
      ),
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: "edit",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Edit message",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 10),
              Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "copy",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Copy message",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 10),
              Icon(Icons.copy, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "delete",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delete message",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.delete, color: Colors.red),
            ],
          ),
        ),
      ],
    );

    if (selectedAction == "delete") {
      FirebaseFirestore.instance
          .collection("chats/${widget.chatId}/messages")
          .doc(messageId)
          .delete();
    }

    if (selectedAction == "edit") {
      if (!isMe) return;

      widget.editMessage(messageId: messageId, message: message);
    }

    if (selectedAction == "copy") {
      await Clipboard.setData(ClipboardData(text: message["text"]));
    }
  }

  @override
  void initState() {
    _messagesStream = FirebaseFirestore.instance
        .collection("chats/${widget.chatId}/messages")
        .orderBy("createdAt", descending: false)
        .snapshots();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: _otherUserLastReadStream,
      builder: (context, lastReadSnapshot) {
        final Timestamp? lastReadOtherUserTimestamp = lastReadSnapshot.data;

        return StreamBuilder(
          stream: _messagesStream,
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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(
                  _scrollController.position.maxScrollExtent,
                );

                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_scrollController.hasClients && mounted) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              }
            });

            return ListView.separated(
              itemCount: loadedMessages.length,
              reverse: false,
              controller: _scrollController,
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

                final messageText = (chatMessage["text"] ?? "").toString();
                final isNextBySameUser = currentUserId == nextUserId;

                final messageId = loadedMessages[index].id;

                final Timestamp? createdAt = chatMessage["createdAt"];
                final isRead =
                    createdAt != null &&
                    lastReadOtherUserTimestamp != null &&
                    lastReadOtherUserTimestamp.compareTo(createdAt) >= 0;

                final bubble = isNextBySameUser
                    ? MessageBubble.next(
                        message: messageText,
                        isMe: isMe,
                        createdAt: createdAt ?? Timestamp(0, 0),
                        isRead: isRead,
                      )
                    : MessageBubble.first(
                        message: messageText,
                        isMe: isMe,
                        createdAt: createdAt ?? Timestamp(0, 0),
                        isRead: isRead,
                      );

                return GestureDetector(
                  onLongPressStart: (details) {
                    _showMessageMenu(
                      globalPosition: details.globalPosition,
                      messageId: messageId,
                      message: chatMessage,
                      isMe: isMe,
                    );
                  },
                  child: bubble,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10);
              },
            );
          },
        );
      },
    );
  }
}
