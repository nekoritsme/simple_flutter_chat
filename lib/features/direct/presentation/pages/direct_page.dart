import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/features/direct/domain/entities/Message.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/edit_message_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/get_current_user_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/get_lastmessage_stream_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/get_participants_usecase.dart';
import 'package:simple_flutter_chat/features/direct/domain/usecases/submit_message_usecase.dart';
import 'package:simple_flutter_chat/features/direct/presentation/widgets/direct_messages.dart';

import '../../domain/usecases/update_lastmessage_usecase.dart';
import '../../domain/usecases/update_lastreadtimestamp_usecase.dart';

enum EditMode { message, edit }

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

  void _updateReadStatus() async {
    final participantsList = await GetParticipantsUseCase().getParticipants(
      widget.chatId,
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

    UpdateLastReadTimestampUseCase().updateLastReadTimestamp(widget.chatId);
  }

  void _setupMessageListener() {
    _messageSubscription = GetLastMessageStreamUseCase()
        .getLastMessageStream(widget.chatId)
        .listen((message) {
          if (message?.messageId != _user.id) {
            _updateReadStatus();
          }
        });
  }

  void _editMessage({
    required String messageId,
    required Map<String, dynamic> message,
  }) {
    setState(() {
      _editMode = EditMode.edit;
      _editMessageId = messageId;
    });

    _messageController.text = message["text"];
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
      widget.chatId,
      _editMessageId!,
      enteredMessage,
    );

    editMessage.fold(
      ifLeft: (_) {},
      ifRight: (_) {
        UpdateLastMessageUseCase().updateLastMessage(
          widget.chatId,
          enteredMessage,
          _editMessageId!,
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
    if (enteredMessage.isEmpty) return;
    FocusScope.of(context).unfocus();

    final submitMessage = await SubmitMessageUseCase().submitMessage(
      widget.chatId,
      enteredMessage,
    );

    submitMessage.fold(
      ifLeft: (_) {
        // TODO: Display error on the screen
      },
      ifRight: (_) {
        UpdateLastMessageUseCase().updateLastMessage(widget.chatId, null, null);
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
              Expanded(
                child: Container(
                  color: theme.colorScheme.onSurface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
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
                            if (_editMode == EditMode.message) {
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
        title: Text(
          widget.chatNickname,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 14),
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
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
