import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteVaultApp extends StatelessWidget {
  const NoteVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    return MaterialApp(
      title: 'NoteVault',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        // Dark gaming theme customization
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFF00E6A8),
          secondary: const Color(0xFF7A5CFF),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF061017),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}