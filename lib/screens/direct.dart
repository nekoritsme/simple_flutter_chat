import 'package:flutter/material.dart';

class DirectMessagesScreen extends StatelessWidget {
  const DirectMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSurface,
      bottomSheet: BottomSheet(
        shape: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurfaceVariant,
            width: 1,
          )
        ),
        onClosing: () {},
        builder: (ctx) => SizedBox(
          width: double.infinity,
          height: 120,
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
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.primary.withAlpha(80),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: theme.colorScheme.primary),
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
                        blurRadius: 30,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    shape: CircleBorder(),
                    backgroundColor: theme.colorScheme.primary,
                    onPressed: () {},
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Nickname holder",
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
    );
  }
}
