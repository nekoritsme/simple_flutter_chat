import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/features/chats/domain/usecases/add_chat_usecase.dart';
import 'package:simple_flutter_chat/features/chats/domain/usecases/get_nickname_usecase.dart';
import 'package:simple_flutter_chat/features/chats/domain/usecases/sign_out_usecase.dart';

import '../widgets/add_chat.dart';
import '../widgets/chat_list.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _userNickname = "Loading...";
  final _searchController = TextEditingController();
  String _searchQuery = "";

  void _scaffoldMessage(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    GetNicknameUseCase().getNickname().then((nickname) {
      setState(() {
        _userNickname = nickname;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onAddChat(String nickname) async {
    try {
      await AddChatUseCase().onAddChat(nickname: nickname);
    } on Left catch (err) {
      _scaffoldMessage(err.value);
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
                  SignOutUsecase().handleSignOut();
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
              controller: _searchController,
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
            Expanded(child: ChatListWidget(searchQuery: _searchQuery)),
          ],
        ),
      ),
    );
  }
}
