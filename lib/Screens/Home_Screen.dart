// File: HomeScreen.dart

import 'package:flutter/material.dart';
import '../Models/home_grid_model.dart'; // Ensure this is lowercase now

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Define the custom color constants used in widgets
  static const Color accentBlue = Color(0xFF53A6FF);
  static const Color cardColor = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    // FIX: Define darkTheme locally if you intend to use it. 
    // However, it's not needed in this specific build method as the style is explicit.
    final ThemeData darkTheme = ThemeData.dark();

    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: Text(
          'Features',
          // Use the context's theme or a defined style
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
              // Correct navigation logic
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: feature.targetScreenBuilder, 
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Widget for the individual feature tile
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
    // FIX: Define darkTheme locally within this build method
    final ThemeData darkTheme = ThemeData.dark(); 

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap, 
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 56.0,
                color: accentBlue,
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                textAlign: TextAlign.center,
                // Use the locally defined darkTheme
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