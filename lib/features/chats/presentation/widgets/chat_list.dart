import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/features/chats/domain/usecases/get_chats_streams_usecase.dart';
import 'package:simple_flutter_chat/features/chats/domain/usecases/get_current_user_usecase.dart';
import 'package:simple_flutter_chat/features/chats/domain/usecases/get_specific_user_stream_usecase.dart';
import 'package:simple_flutter_chat/features/chats/presentation/widgets/chat_item.dart';

import '../../domain/entities/chat.dart';
import '../../domain/usecases/get_unread_count_stream_usecase.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  late final Stream<List<Chat>> _chatsStream;

  Stream<int> _getUnreadCount(String chatId, String userId) {
    return GetUnreadCountStreamUseCase().getUnreadCountStream(
      chatId: chatId,
      userId: userId,
    );
  }

  @override
  void initState() {
    _chatsStream = GetChatsStreamsUseCase().getChatsStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _chatsStream,
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.isEmpty) {
          return const Center(child: Text("No chats found"));
        }

        if (chatSnapshots.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        final loadedChats = chatSnapshots.data!;

        return ListView.builder(
          itemCount: loadedChats.length,
          itemBuilder: (ctx, index) {
            final participants = List<String>.from(
              loadedChats[index].participants,
            );
            final otherUser = participants.firstWhere(
              (id) => id != GetCurrentUserUseCase().getUser().id,
              orElse: () => '',
            );

            if (otherUser.isEmpty) {
              return ChatItemWidget(
                chatNickname: "Invalid chat",
                lastMessage: "",
                lastMessageTimestamp: DateTime(0),
                unreadCount: 0,
                chatId: loadedChats[index].id,
              );
            }

            return StreamBuilder(
              key: ValueKey(loadedChats[index].id),
              stream: GetSpecificUserStreamUseCase().getSpecificUserStream(
                uid: otherUser,
              ),
              builder: (contx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ChatItemWidget(
                    chatNickname: "Loading...",
                    lastMessage: "",
                    lastMessageTimestamp: DateTime(0),
                    unreadCount: 0,
                    chatId: "wait",
                  );
                }

                if (snapshot.hasError) {
                  return ChatItemWidget(
                    chatNickname: "Error loading user",
                    lastMessage: "",
                    lastMessageTimestamp: DateTime(0),
                    unreadCount: 0,
                    chatId: "error",
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return ChatItemWidget(
                    chatNickname: "User not found",
                    lastMessage: "",
                    lastMessageTimestamp: DateTime(0),
                    unreadCount: 0,
                    chatId: "not found",
                  );
                }

                final userData = snapshot.data!;
                final nickname = userData.nickname ?? "Unknown";

                DateTime? time = loadedChats[index].lastMessageTimestamp;
                final lastReadOtherUserTimestamp =
                    loadedChats[index].lastReadTimestamp[otherUser];

                final isRead =
                    time != null &&
                    lastReadOtherUserTimestamp != null &&
                    lastReadOtherUserTimestamp.isAfter(time);

                final isMe =
                    loadedChats[index].lastMessageSenderId ==
                    GetCurrentUserUseCase().getUser().id;

                if (widget.searchQuery.isNotEmpty &&
                    !nickname.toLowerCase().contains(widget.searchQuery)) {
                  return const SizedBox.shrink();
                }

                return StreamBuilder(
                  stream: _getUnreadCount(
                    loadedChats[index].id,
                    GetCurrentUserUseCase().getUser().id,
                  ),
                  builder: (context, unreadSnapshot) {
                    final unreadCount = unreadSnapshot.data ?? 0;

                    return ChatItemWidget(
                      chatNickname: nickname,
                      lastMessage: loadedChats[index].lastMessage,
                      lastMessageTimestamp: time,
                      unreadCount: unreadCount,
                      chatId: loadedChats[index].id,
                      isRead: isRead,
                      isMe: isMe,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
