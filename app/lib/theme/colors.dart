import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBg = Color(
    0xFF05070F,
  ); // Deeper, more immersive dark bg
  static const Color darkSurface = Color(
    0xFF0E1324,
  ); // Richer obsidian-blue slate
  static const Color darkPrimaryGlow = Color(
    0xFF00F2FE,
  ); // Holographic Cyber Cyan
  static const Color darkSecondaryGlow = Color(
    0xFFC084FC,
  ); // Futuristic Violet Glow
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(
    0xFF94A3B8,
  ); // High-contrast tech grey

  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimaryGlow = Color(0xFF0EA5E9);
  static const Color lightSecondaryGlow = Color(0xFF8B5CF6);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);

  static const Color statusWaiting = Color(0xFFEF4444); // Neon Red
  static const Color statusEngaged = Color(0xFFF59E0B); // Cyber Orange
  static const Color statusCompleted = Color(0xFF10B981); // Emerald Green

  static const List<Color> darkBgGradient = [
    Color(0xFF030712),
    Color(0xFF0B1329),
  ];
  static const List<Color> cyberCyanGradient = [
    Color(0xFF00F2FE),
    Color(0xFF4FACFE),
  ];
  static const List<Color> cyberPurpleGradient = [
    Color(0xFFD946EF),
    Color(0xFF8B5CF6),
  ];
  static const List<Color> cyberGoldGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFFD700),
  ];

  static const List<Color> glassBorderGradientDark = [
    Color(0x33FFFFFF),
    Color(0x08FFFFFF),
    Color(0x2600F2FE),
  ];
  static const List<Color> glassBorderGradientLight = [
    Color(0x4D0EA5E9), // 30% Primary Sky/Cyan specular rim
    Color(0x59CBD5E1), // 35% Slate 300 sharp structural edge
    Color(0x6638BDF8), // 40% Bright Sky refractive edge
  ];
}
