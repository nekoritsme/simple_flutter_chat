import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../widgets/add_chat.dart';
import '../widgets/chat_list.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final talker = Talker();
  String _userNickname = "Loading...";

  void _scaffoldMessage(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<String> _getNickname() async {
    final user = FirebaseAuth.instance.currentUser;

    final currentUserNickname = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    return currentUserNickname["nickname"];
  }

  @override
  void initState() {
    _getNickname().then((nickname) {
      setState(() {
        _userNickname = nickname;
      });
    });
    super.initState();
  }

  void _onAddChat(String nickname) async {
    final trimmedNickname = nickname.trim();

    String generateChatId(String userId1, String userId2) {
      final List<String> ids = [userId1, userId2]..sort();

      return ids.join('_');
    }

    try {
      final user = await FirebaseFirestore.instance
          .collection("users")
          .where("nickname", isEqualTo: trimmedNickname)
          .get();

      final bool isUserExists = user.docs.isNotEmpty;
      if (!isUserExists) return _scaffoldMessage("User doesn't exists");

      final currentUser = FirebaseAuth.instance.currentUser!.uid;
      final otherUser = user.docs.first.id;

      final chatId = generateChatId(currentUser, otherUser);
      final chatDoc = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .get();

      if (chatDoc.exists) return _scaffoldMessage("Chat already exists");

      await FirebaseFirestore.instance.collection("chats").doc(chatId).set({
        "participants": [currentUser, otherUser],
        "createdAt": FieldValue.serverTimestamp(),
        "lastMessage": null,
        "lastMessageTimestamp": null,
        "lastReadTimestamp": {
          currentUser: FieldValue.serverTimestamp(),
          otherUser: FieldValue.serverTimestamp(),
        },
      });

      talker.info("Chat has been created");
    } catch (err) {
      talker.error(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.onSurface,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SizedBox(
            width: 10,
            height: 10,
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/profile-picture-holder.jpg",
              ),
            ),
          ),
        ),
        title: Text(_userNickname, style: theme.textTheme.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.colorScheme.primary.withAlpha(90),
              ),
              child: IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: Icon(Icons.exit_to_app, color: theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onPrimary.withAlpha(100),
              blurRadius: 30,
              spreadRadius: -8,
            ),
          ],
        ),
        child: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: theme.colorScheme.primary,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddChatWidget(onAddChat: _onAddChat),
            );
          },
          child: Icon(Icons.add_comment_outlined, color: Colors.white),
        ),
      ),
      backgroundColor: theme.colorScheme.onSurface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chats",
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 40),
            ),
            const SizedBox(height: 15),
            TextField(
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.primary.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: "Search chats",
                hintStyle: TextStyle(color: theme.colorScheme.primary),
                prefixIcon: Icon(
                  size: 25,
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(child: ChatListWidget()),
          ],
        ),
      ),
    );
  }
}
