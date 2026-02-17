import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_flutter_chat/features/auth/presentation/pages/auth_page.dart';
import 'package:simple_flutter_chat/features/chats/presentation/pages/chats_page.dart';
import 'package:simple_flutter_chat/firebase_options.dart';
import 'package:simple_flutter_chat/screens/splash.dart';
import 'package:simple_flutter_chat/service_locator.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'core/sources/firebase_sources.dart';

void main() async {
  final talker = Talker();

  await initializeSingletons();

  runTalkerZonedGuarded(
    talker,
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(ChatApp());
    },
    (error, stackTrace) {
      talker.error(error, stackTrace);
    },
  );
}

// TODO: Make it clear to clean architecture restrictions
class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 19, 164, 236),
          onPrimary: Color.fromARGB(255, 19, 164, 236),
          onSecondary: Color.fromARGB(51, 19, 164, 236),
          onSurface: Color.fromARGB(255, 16, 28, 34),
          onSurfaceVariant: Color.fromARGB(255, 30, 41, 59),
          onTertiary: Color.fromARGB(255, 15, 23, 42),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            color: Color.fromARGB(255, 148, 163, 184),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: StreamBuilder(
        stream: sl<FirebaseAuthSource>().instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          if (snapshot.hasData) {
            return const ChatsScreen();
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
