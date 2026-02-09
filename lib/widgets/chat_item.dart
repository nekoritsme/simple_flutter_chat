import 'package:flutter/material.dart';

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: ListTile(
        title: Text(
          "Placeholder title",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          "Placeholder of last message in that chat.",
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          children: [
            const Text("2m ago"),
            const SizedBox(height: 5),
            const Text("3"),
          ],
        ),
        leading: CircleAvatar(
          backgroundImage: AssetImage(
            "assets/images/profile-picture-holder.jpg",
          ),
        ),
      ),
    );
  }
}
