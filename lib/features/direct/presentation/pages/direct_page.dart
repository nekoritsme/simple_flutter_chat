import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/features/direct/domain/entities/Message.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/edit_message_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/find_messageId_return_nickname_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/get_current_user_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/get_lastmessage_stream_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/get_participants_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/send_image_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/submit_message_usecase.dart';
import 'package:simple_flutter_chat/features/direct/presentation/pages/profile_page.dart';
import 'package:simple_flutter_chat/features/direct/presentation/widgets/direct_messages.dart';

import '../../../chats/domain/usecases/get_specific_user_stream_usecase.dart';
import '../../domain/usecases/get_activity_status_stream_usecase.dart';
import '../../domain/usecases/update_lastmessage_usecase.dart';
import '../../domain/usecases/update_lastreadtimestamp_usecase.dart';

enum EditMode { message, edit, reply }

class DirectMessagesScreen extends StatefulWidget {
  const DirectMessagesScreen({
    super.key,
    required this.chatId,
    required this.chatNickname,
  });

  final String chatId;
  final String chatNickname;

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen>
    with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _user = GetCurrentUserUseCase().getUser();
  StreamSubscription<Message?>? _messageSubscription;
  EditMode _editMode = EditMode.message;
  late List<String> _participants;
  String? _otherUserId;
  String? _editMessageId;
  String? _replyMessageId;
  String? _replyMessage;
  String? _replyTo;

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return "recently was online";
    }

    if (difference.inHours < 1) {
      return "was online ${difference.inMinutes} minutes ago";
    }

    if (difference.inDays < 1) {
      return "was online ${difference.inHours} hours ago";
    }

    if (difference.inDays <= 9) {
      return "was online ${difference.inDays} days ago";
    }

    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  void _updateReadStatus() async {
    final participantsList = await GetParticipantsUseCase().getParticipants(
      chatId: widget.chatId,
    );

    try {
      participantsList.fold(
        ifLeft: (error) {
          return;
        },
        ifRight: (participants) {
          _participants = participants;
        },
      );
    } catch (error) {
      debugPrint("Unexpected participants list error: $error");
    }

    setState(() {
      _otherUserId = _participants.firstWhere((element) => element != _user.id);
    });

    debugPrint("Participants: $_participants");

    UpdateLastReadTimestampUseCase().updateLastReadTimestamp(
      chatId: widget.chatId,
    );
  }

  void _sendImage() {
    SendImageUseCase().call(
      chatId: widget.chatId,
      replyMessageId: _replyMessageId,
      replyMessage: _replyMessage,
    );
  }

  void _setupMessageListener() {
    _messageSubscription = GetLastMessageStreamUseCase()
        .getLastMessageStream(chatId: widget.chatId)
        .listen((message) {
          if (message?.messageId != _user.id) {
            _updateReadStatus();
          }
        });
  }

  void _onReplyMessage({required String messageId, required String message}) {
    setState(() {
      _editMode = EditMode.reply;
      _replyMessageId = messageId;
      _replyMessage = message;
      _replyTo = FindMessageIdReturnNicknameUseCase().call(
        messageId: messageId,
      );
    });
  }

  void _editMessage({required String messageId, required Message message}) {
    setState(() {
      _editMode = EditMode.edit;
      _editMessageId = messageId;
    });

    _messageController.text = message.text;
  }

  void _editMessageConfirm() async {
    setState(() {
      _editMode = EditMode.message;
    });

    if (_editMessageId == null || _messageController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    final enteredMessage = _messageController.text;
    _messageController.clear();

    final editMessage = await EditMessageUseCase().editMessage(
      chatId: widget.chatId,
      messageId: _editMessageId!,
      newMessage: enteredMessage,
    );

    editMessage.fold(
      ifLeft: (_) {},
      ifRight: (_) {
        UpdateLastMessageUseCase().updateLastMessage(
          chatId: widget.chatId,
          compareWithMessage: enteredMessage,
          compareWithMessageId: _editMessageId!,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _updateReadStatus();
    _setupMessageListener();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _updateReadStatus();
    } else if (state == AppLifecycleState.resumed) {
      _updateReadStatus();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageSubscription?.cancel();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (_editMode == EditMode.reply) {
      setState(() {
        _editMode = EditMode.message;
      });
    }

    if (_editMode == EditMode.message) {
      setState(() {
        _editMode = EditMode.message;
      });
    }

    if (enteredMessage.isEmpty) return;
    if (enteredMessage.trim().isEmpty) return;
    FocusScope.of(context).unfocus();

    final submitMessage = await SubmitMessageUseCase().submitMessage(
      chatId: widget.chatId,
      message: enteredMessage,
      replyMessageId: _replyMessageId,
      replyMessage: _replyMessage,
    );

    submitMessage.fold(
      ifLeft: (_) {
        // TODO: Display error on the screen
      },
      ifRight: (_) {
        UpdateLastMessageUseCase().updateLastMessage(
          chatId: widget.chatId,
          compareWithMessage: null,
          compareWithMessageId: null,
        );
      },
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSurface,
      bottomSheet: BottomSheet(
        shape: Border(
          top: BorderSide(color: theme.colorScheme.onSurfaceVariant, width: 1),
        ),
        onClosing: () {},
        builder: (ctx) => SizedBox(
          width: double.infinity,
          height: _editMode == EditMode.message ? 120 : 170,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_editMode == EditMode.edit)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  height: 50,
                  color: theme.colorScheme.onTertiary.withAlpha(240),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit, color: theme.colorScheme.primary),
                          const SizedBox(width: 5),
                          Text(
                            "EDITING MESSAGE",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _editMode = EditMode.message;
                          });
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.textTheme.bodyMedium!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_editMode == EditMode.reply)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  height: 50,
                  color: theme.colorScheme.onTertiary.withAlpha(240),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.reply, color: theme.colorScheme.primary),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Replaying to $_replyTo",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 250,
                                child: Text(
                                  _replyMessage ?? "failed",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _editMode = EditMode.message;
                            _replyMessageId = null;
                            _replyMessage = null;
                          });
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.textTheme.bodyMedium!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  color: theme.colorScheme.onSurface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.onSurfaceVariant,
                          child: IconButton(
                            onPressed: _sendImage,
                            icon: Icon(Icons.add),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: TextField(
                            controller: _messageController,
                            style: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.primary.withAlpha(
                                80,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: "Type a message",
                              hintStyle: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.only(right: 16),
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
                        child: FloatingActionButton(
                          shape: CircleBorder(),
                          backgroundColor: theme.colorScheme.primary,
                          onPressed: () {
                            if (_editMode == EditMode.message ||
                                _editMode == EditMode.reply) {
                              return _submitMessage();
                            }
                            if (_editMode == EditMode.edit) {
                              return _editMessageConfirm();
                            }
                          },
                          child: Icon(
                            _editMode == EditMode.message
                                ? Icons.send
                                : Icons.check,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: StreamBuilder(
          stream: GetSpecificUserStreamUseCase().getSpecificUserStream(
            uid: _otherUserId ?? "",
          ),
          builder: (context, userProfileSnapshot) {
            if (userProfileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Text("Loading");
            }

            if (userProfileSnapshot.hasError) {
              return Text("Error");
            }

            if (!userProfileSnapshot.hasData) {
              return Text("No data found");
            }

            final data = userProfileSnapshot.data!;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      username: data.nickname ?? "",
                      profilePictureUrl: data.profilePictureUrl ?? "",
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Hero(
                    tag: "photo",
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        data.profilePictureUrl ?? "",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chatNickname,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      if (_otherUserId == null)
                        Text(
                          "Loading",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 12,
                          ),
                        )
                      else
                        StreamBuilder(
                          stream: GetActivityStatusStreamUseCase()
                              .getActivityStatusStream(userId: _otherUserId!),
                          builder: (context, activityStatusSnapshot) {
                            if (activityStatusSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("Loading");
                            }

                            if (activityStatusSnapshot.hasError) {
                              return Text("Error");
                            }

                            if (!activityStatusSnapshot.hasData) {
                              return Text("No data found");
                            }

                            final data = activityStatusSnapshot.data!;

                            return Text(
                              data.isOnline
                                  ? "Online"
                                  : _formatDate(data.lastSeen),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 12,
                                color: Colors.white.withAlpha(150),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        backgroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: DirectMessagesWidget(
              chatId: widget.chatId,
              editMessage: _editMessage,
              otherUserId: _otherUserId ?? "",
              onReplyMessage: _onReplyMessage,
              otherUserNickname: widget.chatNickname,
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
