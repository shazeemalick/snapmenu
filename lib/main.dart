import 'package:flutter/material.dart';
import 'package:easy_menu/utils/app_theme.dart';
import 'package:easy_menu/screens/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapMenu',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
