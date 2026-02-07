import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:easy_menu/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_menu/models/menu_item.dart';
import 'package:easy_menu/utils/app_colors.dart';
import 'package:easy_menu/widgets/smart_budget_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatefulWidget {
  final List<MenuItem> items;
  final String imagePath;
  final bool isHistory; // Flag to prevent duplicate saves

  const ResultScreen({
    super.key,
    required this.items,
    required this.imagePath,
    this.isHistory = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<MenuItem> _filteredItems = [];
  double? _activeBudget;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    
    // Only save to history if it's a fresh scan (not coming from history tab)
    if (!widget.isHistory) {
      _saveToHistory();
    }
  }

  Future<void> _saveToHistory() async {
    if (kIsWeb) return; // Saving to local file system not supported on web
    try {
      final dbService = DatabaseService();
      
      if (widget.imagePath.isNotEmpty && widget.items.isNotEmpty) {
        final appDir = await getApplicationDocumentsDirectory();
        
        // If imagePath is already inside appDir, no need to copy
        if (widget.imagePath.contains(appDir.path)) {
          await dbService.saveScan(widget.imagePath, widget.items);
          return;
        }

        final fileName = "scan_${DateTime.now().millisecondsSinceEpoch}${path.extension(widget.imagePath)}";
        final permanentPath = path.join(appDir.path, fileName);
        
        final originalFile = File(widget.imagePath);
        if (await originalFile.exists()) {
          await originalFile.copy(permanentPath);
          await dbService.saveScan(permanentPath, widget.items);
        } else {
          debugPrint("Original image path does not exist: ${widget.imagePath}");
        }
      }
    } catch (e) {
      debugPrint("Error saving to history: $e");
    }
  }

  void _applyBudgetFilter(double budget) {
    setState(() {
      _activeBudget = budget;
      _filteredItems = widget.items.where((item) {
        if (item.variations != null && item.variations!.isNotEmpty) {
          return item.variations!.any((v) => v.price <= budget);
        }
        return item.price <= budget;
      }).toList();
    });
  }

  void _resetFilter() {
    setState(() {
      _activeBudget = null;
      _filteredItems = widget.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Menu Decoded",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_activeBudget != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.error),
              onPressed: _resetFilter,
              tooltip: "Clear Filter",
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => SmartBudgetDialog(onBudgetApplied: _applyBudgetFilter),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.savings_rounded),
        label: const Text("Smart Budget"),
      ),
      body: Column(
        children: [
          if (_activeBudget != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Showing items under ${_activeBudget!.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      _activeBudget != null 
                          ? "No items found under this budget."
                          : "No items found.\nTry a clearer picture.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _buildMenuCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuItem item) {
    final hasVariations = item.variations != null && item.variations!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildCategoryBadge(item.category),
                  ],
                ),
              ),
              if (!hasVariations)
                Text(
                  "${item.price.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (hasVariations) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.white10),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.variations!.map((v) => _buildVariationChip(v)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVariationChip(MenuVariation v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${v.size}: ",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            v.price.toStringAsFixed(0),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
