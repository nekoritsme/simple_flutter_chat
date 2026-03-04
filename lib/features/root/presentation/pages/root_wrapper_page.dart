import 'package:flutter/material.dart';
import 'package:simple_flutter_chat/features/chats/presentation/pages/chats_page.dart';
import 'package:simple_flutter_chat/features/settings/presentation/pages/settings_page.dart';

class RootWrapperPage extends StatefulWidget {
  const RootWrapperPage({super.key});

  @override
  State<RootWrapperPage> createState() => _RootWrapperPageState();
}

class _RootWrapperPageState extends State<RootWrapperPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: theme.colorScheme.onSurface,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        labelTextStyle: WidgetStatePropertyAll(
          theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(
              Icons.chat_bubble,
              color: theme.colorScheme.onPrimary,
              size: 40,
            ),
            icon: Icon(
              Icons.chat_bubble,
              color: theme.colorScheme.outline,
              size: 40,
            ),
            label: "Chats",
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.settings,
              color: theme.colorScheme.onPrimary,
              size: 40,
            ),
            icon: Icon(
              Icons.settings,
              color: theme.colorScheme.outline,
              size: 40,
            ),
            label: "Settings",
          ),
        ],
      ),
      body: currentPageIndex == 0 ? ChatsScreen() : SettingsPage(),
    );
  }
}
