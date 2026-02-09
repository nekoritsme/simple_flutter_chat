import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../widgets/auth_tabs.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final talker = Talker();

  void _scaffoldMessage(String? msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg ?? "Authentication failed")));
  }

  void _handleLogin(String email, String password) async {
    try {
      final userCredentials = await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      talker.info("User credentials logined: $userCredentials");
    } on FirebaseAuthException catch (err) {
      _scaffoldMessage(err.message);
    }
  }

  void _handleSignup(String nickname, String email, String password) async {
    try {
      final userCredentials = await _firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      talker.info("User credentials registred: $userCredentials");

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredentials.user!.uid)
          .set({
            "nickname": nickname,
            "email": email,
            "createdAt": Timestamp.now(),
          });
    } on FirebaseAuthException catch (err) {
      _scaffoldMessage(err.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSurface,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(24),
              ),
              width: 80,
              height: 80,
              child: Icon(
                Icons.chat_bubble,
                size: 50,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text("Welcome Back", style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              "Connect with your inner circle instantly\nand securely.",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AuthTabsWidget(
                onLogin: _handleLogin,
                onSignup: _handleSignup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
