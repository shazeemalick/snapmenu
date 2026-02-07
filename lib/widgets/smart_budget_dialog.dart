import 'package:flutter/material.dart';
import 'package:easy_menu/utils/app_colors.dart';
import 'package:easy_menu/widgets/primary_button.dart';
import 'package:google_fonts/google_fonts.dart';

class SmartBudgetDialog extends StatefulWidget {
  final Function(double) onBudgetApplied;

  const SmartBudgetDialog({super.key, required this.onBudgetApplied});

  @override
  State<SmartBudgetDialog> createState() => _SmartBudgetDialogState();
}

class _SmartBudgetDialogState extends State<SmartBudgetDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Smart Budget 💰",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Enter your budget to find the best meals for you.",
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "e.g., 500",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: "Find Meals",
              onPressed: () {
                final budget = double.tryParse(_controller.text);
                if (budget != null) {
                  widget.onBudgetApplied(budget);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
