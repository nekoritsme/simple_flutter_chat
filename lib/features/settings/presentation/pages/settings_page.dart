import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/features/settings/domain/usecases/get_current_user_usecase.dart';
import 'package:simple_flutter_chat/features/settings/domain/usecases/get_specific_user_stream_usecase.dart';
import 'package:simple_flutter_chat/features/settings/domain/usecases/pick_image_usecase.dart';

import '../../../chats/domain/usecases/get_nickname_usecase.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _nickname;

  @override
  void initState() {
    GetNicknameUseCase().getNickname().then((nickname) {
      setState(() {
        _nickname = nickname;
      });
    });
    super.initState();
  }

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
                  child: StreamBuilder(
                    stream: GetSpecificUserStreamUseCase()
                        .getSpecificUserStream(
                          uid: GetCurrentUserUseCase().getUser().id,
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data == null) {
                        return const CircleAvatar(
                          backgroundImage: AssetImage(
                            "assets/images/profile-picture-holder.jpg",
                          ),
                        );
                      }

                      if (snapshot.data!.profilePictureUrl == null) {
                        return const CircleAvatar(
                          backgroundImage: AssetImage(
                            "assets/images/profile-picture-holder.jpg",
                          ),
                        );
                      }

                      final userData = snapshot.data!;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GalleryPage(
                                imageProvider: NetworkImage(
                                  userData.profilePictureUrl!,
                                ),
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            userData.profilePictureUrl!,
                          ),
                        ),
                      );
                    },
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
            const SizedBox(height: 15),
            Text(
              "@${_nickname ?? "Unknown"}",
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
