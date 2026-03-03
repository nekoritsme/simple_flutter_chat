import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/features/settings/domain/usecases/pick_image_usecase.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onSurface,
      appBar: AppBar(
        title: Text("Settings", style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/images/profile-picture-holder.jpg",
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      PickImageUseCase().pickImageAndUpload();
                    },
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.onPrimary,
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
