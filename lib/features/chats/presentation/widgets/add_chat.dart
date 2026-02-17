import 'package:flutter/material.dart';

class AddChatWidget extends StatefulWidget {
  const AddChatWidget({super.key, required this.onAddChat});

  final Function(String nickname) onAddChat;

  @override
  State<AddChatWidget> createState() => _AddChatWidgetState();
}

class _AddChatWidgetState extends State<AddChatWidget> {
  String _enteredNickname = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        "Add New Chat",
        style: theme.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      shape: OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 51, 65, 85)),
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: theme.colorScheme.onSurface,
      content: SizedBox(
        width: 300,
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Connect with someone new",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "ENTER NICKNAME",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            TextField(
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.primary.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: "nickname",
                hintStyle: TextStyle(color: theme.colorScheme.primary),
                prefixIcon: Icon(
                  size: 25,
                  Icons.alternate_email_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              onChanged: (value) {
                _enteredNickname = value;
              },
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.onPrimary.withAlpha(100),
                    blurRadius: 30,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.onPrimary,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: () {
                  if (_enteredNickname.isEmpty ||
                      _enteredNickname.trim().length < 3 ||
                      _enteredNickname.trim().length > 10) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please enter valid nickname",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    );

                    return;
                  }

                  widget.onAddChat(_enteredNickname);
                  Navigator.pop(context);
                },
                child: Text(
                  "Add",
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 19),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
