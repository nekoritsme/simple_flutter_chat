import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/widgets/chat_item.dart';

import '../widgets/add_chat.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  void _onAddChat(String nickname) {}

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
                hintText: "Search messages",
                hintStyle: TextStyle(color: theme.colorScheme.primary),
                prefixIcon: Icon(
                  size: 25,
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ChatItemWidget(),
            // maybe ListView idk
            // ListView.builder(itemBuilder: itemBuilder)
          ],
        ),
      ),
    );
  }
}
