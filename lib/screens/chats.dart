import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsSreen extends StatefulWidget {
  const ChatsSreen({super.key});

  @override
  State<ChatsSreen> createState() => _ChatsSreenState();
}

class _ChatsSreenState extends State<ChatsSreen> {
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
          ],
        ),
      ),
    );
  }
}
