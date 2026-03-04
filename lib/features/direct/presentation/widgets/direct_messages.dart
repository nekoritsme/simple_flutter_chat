import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/delete_message_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/init_messages_stream_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/load_older_messages_usecase.dart';
import 'package:simple_flutter_chat/features/direct/presentation/widgets/message_bubble.dart';
import 'package:vibration/vibration.dart';

import '../../domain/entities/Message.dart';
import '../../domain/usecases/get_messages_stream_usecase.dart';
import 'date_separator.dart';

class DirectMessagesWidget extends StatefulWidget {
  const DirectMessagesWidget({
    super.key,
    required this.chatId,
    required this.editMessage,
    required this.otherUserId,
  });

  final Function({required String messageId, required Message message})
  editMessage;

  final String chatId;
  final String otherUserId;

  @override
  State<DirectMessagesWidget> createState() => _DirectMessagesWidgetState();
}

class _DirectMessagesWidgetState extends State<DirectMessagesWidget> {
  final _scrollController = ScrollController();
  bool _didInitialAutoScroll = false;
  String? _lastNewestMessageId;
  bool _isLoadingOlder = false;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateSeparator(DateTime value) {
    final date = value.toLocal();
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) return "Today";
    if (diffDays == 1) return "Yesterday";

    if (diffDays > 1 && diffDays < 7) {
      return DateFormat("EEEE").format(date);
    }

    if (date.year == now.year) {
      return DateFormat("d MMMM").format(date);
    }

    return DateFormat("dd/MM/yyyy").format(date);
  }

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
    required Message message,
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
      await DeleteMessageUseCase().deleteMessage(
        chatId: widget.chatId,
        messageId: messageId,
      );
    }

    if (selectedAction == "edit") {
      if (!isMe) return;

      widget.editMessage(messageId: messageId, message: message);
    }

    if (selectedAction == "copy") {
      await Clipboard.setData(ClipboardData(text: message.text));
    }
  }

  Future<void> _loadOlderPreservePosition() async {
    if (_isLoadingOlder || !_scrollController.hasClients) return;
    _isLoadingOlder = true;

    final oldOffset = _scrollController.offset;
    final oldMaxScroll = _scrollController.position.maxScrollExtent;

    try {
      await LoadOlderMessagesUseCase().loadOlderMessages();
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients || !mounted) {
          _isLoadingOlder = false;
          return;
        }

        final newMaxScroll = _scrollController.position.maxScrollExtent;
        final delta = newMaxScroll - oldMaxScroll;
        final targetOffset = oldOffset + delta;

        _scrollController.jumpTo(
          targetOffset.clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          ),
        );
        _isLoadingOlder = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.offset <=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadOlderPreservePosition();
    }
  }

  void _autoScrollIfNeeded(List<Message> messages) {
    if (messages.isEmpty) return;

    final newestMessageId = messages.last.messageId;
    final hasNewBottomMessage =
        _lastNewestMessageId != null && newestMessageId != _lastNewestMessageId;
    final isNearBottom =
        !_scrollController.hasClients ||
        (_scrollController.position.maxScrollExtent -
                _scrollController.offset) <=
            160;
    final shouldAutoScroll =
        !_didInitialAutoScroll || (hasNewBottomMessage && isNearBottom);

    _lastNewestMessageId = newestMessageId;
    if (!shouldAutoScroll) return;

    _didInitialAutoScroll = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || !mounted) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    InitMessagesStreamUseCase().init(chatId: widget.chatId);
    _scrollController.addListener(_onScroll);
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
        DateTime? lastReadOtherUserTimestamp;
        final data = lastReadSnapshot.data;
        if (data != null && data is Timestamp) {
          lastReadOtherUserTimestamp = data.toDate();
        }

        return StreamBuilder(
          stream: GetMessagesStreamUseCase().getMessagesStream(),
          builder: (ctx, messagesSnapshots) {
            if (messagesSnapshots.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!messagesSnapshots.hasData || messagesSnapshots.data!.isEmpty) {
              return const Center(child: Text("No messages was found"));
            }

            if (messagesSnapshots.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            final loadedMessages = messagesSnapshots.data!;
            _autoScrollIfNeeded(loadedMessages);

            return ListView.separated(
              itemCount: loadedMessages.length,
              reverse: false,
              controller: _scrollController,
              itemBuilder: (contx, index) {
                final chatMessage = loadedMessages[index];
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1]
                    : null;
                final prevChatMessage = index - 1 >= 0
                    ? loadedMessages[index - 1]
                    : null;
                final localCreatedAtMsg = chatMessage.createdAt.toLocal();
                final localCreatedAtPrevMsg = prevChatMessage?.createdAt
                    .toLocal();
                final separate =
                    localCreatedAtPrevMsg == null ||
                    !_isSameDay(localCreatedAtMsg, localCreatedAtPrevMsg);

                final isMe = chatMessage.userId == authenticatedUser!.uid;

                final currentUserId = chatMessage.userId;
                final nextUserId = nextChatMessage?.userId;

                final messageText = (chatMessage.text).toString();
                final isNextBySameUser = currentUserId == nextUserId;

                final messageId = loadedMessages[index].messageId;

                final DateTime createdAt = chatMessage.createdAt;
                final isRead =
                    lastReadOtherUserTimestamp != null &&
                    lastReadOtherUserTimestamp.isAfter(createdAt);

                final isEdited = chatMessage.editedAt != null;

                final bubble = isNextBySameUser
                    ? MessageBubble.next(
                        message: messageText,
                        isMe: isMe,
                        createdAt: createdAt,
                        isRead: isRead,
                        isEdited: isEdited,
                      )
                    : MessageBubble.first(
                        message: messageText,
                        isMe: isMe,
                        createdAt: createdAt,
                        isRead: isRead,
                        isEdited: isEdited,
                        profileUrl: chatMessage.profileUrl,
                      );

                return Column(
                  children: [
                    if (separate)
                      SizedBox(
                        height: 30,
                        child: DateSeparatorWidget(
                          dateString: _formatDateSeparator(localCreatedAtMsg),
                        ),
                      ),
                    GestureDetector(
                      onLongPressStart: (details) {
                        _showMessageMenu(
                          globalPosition: details.globalPosition,
                          messageId: messageId,
                          message: chatMessage,
                          isMe: isMe,
                        );
                      },
                      child: bubble,
                    ),
                  ],
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
