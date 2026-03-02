import 'package:flutter/material.dart';

class GameConstants {
  // Colores
  static const Color deepBlue = Color(0xFF1A1A6E);
  static const Color neonCyan = Color(0xFF00B4D8);
  static const Color galaxyPurple = Color(0xFF4B0082);
  static const Color gold = Color(0xFFFFD700);
  static const Color softPink = Color(0xFFFFB3C6);
  
  // Física
  static const double floatStrength = 0.08;
  static const double spaceFriction = 0.85;
  static const double anchorDistance = 5.0;
  
  // Gameplay
  static const int levelsPerGalaxy = 15;
  static const int failsBeforeInterstitial = 3;
  static const double patternMemoryTime = 5.0; // segundos
}
