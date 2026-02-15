import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/widgets/direct_messages.dart';
import 'package:talker_flutter/talker_flutter.dart';

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
  final talker = Talker();
  final _user = FirebaseAuth.instance.currentUser;
  StreamSubscription<QuerySnapshot>? _messageSubscription;
  EditMode _editMode = EditMode.message;
  String? _editMessageId;

  void _updateReadStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.chatId)
          .update({
            "lastReadTimestamp.${_user!.uid}": FieldValue.serverTimestamp(),
          });
    } catch (err, stack) {
      talker.error(err, stack);
    }
  }

  void _setupMessageListener() {
    _messageSubscription = FirebaseFirestore.instance
        .collection("chats/${widget.chatId}/messages")
        .orderBy("createdAt", descending: false)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final messageData = change.doc.data();

              if (messageData?["userId"] != _user!.uid) {
                _updateReadStatus();
              }
            }
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
    talker.info("Am i here?");
    final enteredMessage = _messageController.text;
    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection("chats/${widget.chatId}/messages")
          .doc(_editMessageId)
          .update({
            "text": enteredMessage,
            "editedAt": FieldValue.serverTimestamp(),
          });
    } catch (err, stack) {
      talker.error(err, stack);
    }
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
    talker.info(enteredMessage);
    if (enteredMessage.isEmpty) return;
    FocusScope.of(context).unfocus();

    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(_user!.uid)
        .get();

    await FirebaseFirestore.instance
        .collection("chats/${widget.chatId}/messages")
        .add({
          "text": enteredMessage,
          "createdAt": FieldValue.serverTimestamp(),
          "userId": FirebaseAuth.instance.currentUser!.uid,
          "nickname": userData.data()!["nickname"],
        });

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .update({
          "lastMessageTimestamp": FieldValue.serverTimestamp(),
          "lastMessage": enteredMessage,
        });

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
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
