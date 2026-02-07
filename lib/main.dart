import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  final talker = Talker();

  runTalkerZonedGuarded(
    talker,
    () {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(ChatApp());
    },
    (error, stackTrace) {
      talker.error(error, stackTrace);
    },
  );
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(1, 19, 236, 1),
        ),
      ),
      home: const Placeholder(),
    );
  }
}
