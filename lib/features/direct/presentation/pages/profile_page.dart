import 'package:flutter/material.dart';

import '../../../gallery/presentation/pages/gallery_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.username,
    required this.profilePictureUrl,
  });

  final String username;
  final String profilePictureUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSurface,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryPage(
                    imageProvider: NetworkImage(profilePictureUrl),
                  ),
                ),
              );
            },
            child: Center(
              child: Hero(
                tag: "photo",
                child: CircleAvatar(
                  radius: 65,
                  backgroundImage: NetworkImage(profilePictureUrl),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            username,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
