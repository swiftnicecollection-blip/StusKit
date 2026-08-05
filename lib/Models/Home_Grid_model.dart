import 'package:flutter/material.dart';
import 'package:team_project/Screens/Calendar.dart';
import 'package:team_project/Screens/Image_to_text.dart';
import 'package:team_project/Screens/OCR_Screen.dart';
import 'package:team_project/Screens/QR_code_screen.dart';
import 'package:team_project/Screens/voice_to_text_Screen.dart';
import '../Screens/text_to_speech_screen.dart';


class HomeGridModel {
  final String title;
  final IconData icon;
  // A WidgetBuilder (function) to create the target screen/route
  final WidgetBuilder targetScreenBuilder;

  // Keep the constructor const, as all fields are final
  const HomeGridModel({
    required this.title,
    required this.icon,
    required this.targetScreenBuilder,
  });
}


final List<HomeGridModel> featuresList = [
  HomeGridModel(
    title: 'Text to Speech',
    icon: Icons.mic_external_on_outlined,
    targetScreenBuilder: (context) =>  TextToSpeechScreen(),
  ),
  HomeGridModel(
    title: 'Image to text',
    icon: Icons.image_outlined,
    targetScreenBuilder: (context) => Image_to_text(),
  ),
  HomeGridModel(
    title: 'Voice to text',
    icon: Icons.mic_none_outlined,
    targetScreenBuilder: (context) => Voice_to_text(),
  ),
  HomeGridModel(
    title: 'Language translator',
    icon: Icons.translate_outlined,
    targetScreenBuilder: (context) =>  OCRScreen(),
  ),
  HomeGridModel(
    title: 'Calendar and Events',
    icon: Icons.calendar_today_outlined,
    targetScreenBuilder: (context) =>  Calendar(),
  ),
  HomeGridModel(
    title: 'Qr code Scan',
    icon: Icons.qr_code_scanner_outlined,
    targetScreenBuilder: (context) =>  QrScannerScreen(),
  ),
];