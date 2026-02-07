import 'package:flutter/material.dart';

class AppColors {
  // Premium Dark Theme Palette
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFFFF6B6B); // Vulnerant Red/Coral
  static const Color secondary = Color(0xFFFFD93D); // Gold/Yellow accent
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
