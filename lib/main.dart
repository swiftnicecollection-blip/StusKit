import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:team_project/Screens/Home_Screen.dart';
import 'constants.dart'; // Import the colors

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Hive and open the required box
  await Hive.initFlutter();
  await Hive.openBox('notesBox');

  // 3. Run the application
  runApp(const VoiceNoteApp());
}

class VoiceNoteApp extends StatelessWidget {
  const VoiceNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice NoteVault',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackgroundColor,
        cardColor: cardColor,
        primaryColor: accentBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentBlue,
          brightness: Brightness.dark,
          // Set primary container colors
          primary: accentBlue,
          onPrimary: onPrimaryWhite,
          background: darkBackgroundColor,
          surface: cardColor,
        ),
        textTheme: const TextTheme(
          // For the "Voice to Text Converter" title
          headlineLarge: TextStyle(color: onPrimaryWhite, fontWeight: FontWeight.bold, fontSize: 32), 
          // For the list tile text (Note Preview)
          bodyMedium: TextStyle(color: onPrimaryWhite, fontSize: 16), 
        ),
        iconTheme: const IconThemeData(
          color: onPrimaryWhite,
        ),
        useMaterial3: true,
        
        // --- Custom Component Themes for UI Consistency ---
        
        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackgroundColor,
          elevation: 0,
          titleTextStyle: TextStyle(color: onPrimaryWhite, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        
        // Input Field Theme (for Search and Note Input)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor.withOpacity(0.8),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: accentBlue, width: 2), // Accent focus border
          ),
          hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.8)),
          prefixIconColor: secondaryTextColor,
          suffixIconColor: secondaryTextColor,
        ),
        
        // ElevatedButton (for Save button)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentBlue,
            foregroundColor: onPrimaryWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        
        // OutlinedButton (for Clear button)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: secondaryTextColor,
            side: BorderSide(color: secondaryTextColor.withOpacity(0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
        
        // Dialog Theme
        dialogTheme: DialogThemeData(
          backgroundColor: cardColor,
          titleTextStyle: const TextStyle(color: onPrimaryWhite, fontWeight: FontWeight.bold, fontSize: 20),
          contentTextStyle: const TextStyle(color: onPrimaryWhite),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        
        // Text Button (for dialog actions)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accentBlue,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}