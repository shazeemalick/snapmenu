import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_menu/utils/app_colors.dart';
import 'package:easy_menu/utils/app_theme.dart';
import 'package:easy_menu/screens/onboarding/onboarding_screen.dart';
import 'package:easy_menu/screens/dashboard/dashboard_screen.dart';
import 'package:easy_menu/services/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final userName = await DatabaseService().getUserName();

    if (userName != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/images/icon/playstore.png',
              width: 120,
              height: 120,
            ).animate().fade(duration: 800.ms).scale(delay: 400.ms),
            const SizedBox(height: 20),
            // App Name
            Text(
              "SnapMenu",
              style: AppTheme.darkTheme.textTheme.displayLarge,
            ).animate().fadeIn(delay: 800.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 10),
            // Tagline
            Text(
              "Smart Menu Digitizer",
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ).animate().fadeIn(delay: 1200.ms),
          ],
        ),
      ),
    );
  }
}
