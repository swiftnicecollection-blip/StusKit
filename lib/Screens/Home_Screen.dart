// File: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
// FIX 1: Path changed to lowercase 'models'
import '../models/home_grid_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color accentBlue = Color(0xFF53A6FF);
  static const Color cardColor = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    final ThemeData darkTheme = ThemeData.dark();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Features',
          style: darkTheme.textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
          children: featuresList.map((feature) {
            return FeatureTile(
              title: feature.title,
              icon: feature.icon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: feature.targetScreenBuilder),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  static const Color accentBlue = HomeScreen.accentBlue;
  static const Color cardColor = HomeScreen.cardColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData darkTheme = ThemeData.dark();

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 56.0, color: accentBlue),
              const SizedBox(height: 16.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: darkTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
