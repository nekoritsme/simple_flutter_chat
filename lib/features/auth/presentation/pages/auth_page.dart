import 'package:dart_either/dart_either.dart';
import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/features/auth/domain/usecases/LoginUseCase.dart';
import 'package:simple_flutter_chat/features/auth/domain/usecases/SignUpUseCase.dart';

import '../widgets/auth_tabs.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void _scaffoldMessage(String? msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg ?? "Authentication failed")));
  }

  void _handleLogin(String email, String password) async {
    try {
      LoginUseCase().handleLogin(email: email, password: password);
    } on Left catch (err) {
      _scaffoldMessage(err.value);
    }
  }

  void _handleSignup(String nickname, String email, String password) async {
    try {
      SignUpUseCase().handleSignUp(
        email: email,
        password: password,
        nickname: nickname,
      );
    } on Left catch (err) {
      _scaffoldMessage(err.value);
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
