import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_flutter_chat/firebase_options.dart';
import 'package:simple_flutter_chat/screens/auth.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  final talker = Talker();

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
      home: AuthScreen(),
    );
  }
}
