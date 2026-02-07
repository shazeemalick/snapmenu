import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_menu/utils/app_colors.dart';
import 'package:easy_menu/widgets/primary_button.dart';
import 'package:easy_menu/screens/dashboard/dashboard_screen.dart';
import 'package:easy_menu/screens/auth/name_input_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _contents = [
    {
      "title": "Scan Menus Instantly",
      "desc": "Just point your camera at any restaurant menu to digitize it in seconds.",
      "image": "assets/images/scan.png", // We'll use Icons for now
    },
    {
      "title": "Smart AI Pricing",
      "desc": "Automatically extract prices and organize items by category.",
      "image": "assets/images/ai.png",
    },
    {
      "title": "Order Smarter",
      "desc": "Filter by budget, find the best deals, and verify total cost before ordering.",
      "image": "assets/images/order.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(
                    title: _contents[index]["title"]!,
                    desc: _contents[index]["desc"]!,
                    icon: index == 0
                        ? Icons.camera_alt_outlined
                        : index == 1
                            ? Icons.auto_awesome_outlined
                            : Icons.shopping_bag_outlined,
                  );
                },
              ),
            ),
            _buildIndicators(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: _currentIndex == _contents.length - 1
                    ? "Get Started"
                    : "Next",
                onPressed: () {
                  if (_currentIndex == _contents.length - 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NameInputScreen()),
                    );
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
      {required String title, required String desc, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 80,
              color: AppColors.primary,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _contents.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? AppColors.primary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
