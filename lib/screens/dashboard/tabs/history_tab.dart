import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:easy_menu/utils/app_colors.dart';
import 'package:easy_menu/services/database_service.dart';
import 'package:easy_menu/models/menu_item.dart';
import 'package:easy_menu/screens/results/result_screen.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final _dbService = DatabaseService();
  List<Map<String, dynamic>> _scans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final scans = await _dbService.getScans();
    setState(() {
      _scans = scans;
      _isLoading = false;
    });
  }

  Future<void> _deleteHistoryItem(int id) async {
    await _dbService.deleteScan(id);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_scans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 80, color: AppColors.surface),
            const SizedBox(height: 16),
            Text(
              "No history yet",
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _scans.length,
      itemBuilder: (context, index) {
        final scan = _scans[index];
        final results = jsonDecode(scan['results_json']) as List;
        final items = results.map((e) => MenuItem.fromJson(e)).toList();
        final date = DateTime.parse(scan['scanned_at']);
        final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Container(
                      width: 60,
                      height: 60,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.cloud_off_rounded, color: AppColors.primary),
                    )
                  : Image.file(
                      File(scan['image_path']),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.white10,
                        child: const Icon(Icons.image_not_supported, color: Colors.white24),
                      ),
                    ),
            ),
            title: Text(
              "${items.length} Items Found",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _showDeleteConfirmation(scan['id']),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    items: items,
                    imagePath: scan['image_path'],
                    isHistory: true, // Crucial: prevent duplicate saves
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Delete Scan", style: GoogleFonts.poppins(color: Colors.white)),
        content: Text("Are you sure you want to remove this scan from history?",
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              _deleteHistoryItem(id);
              Navigator.pop(context);
            },
            child: Text("Delete", style: GoogleFonts.poppins(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
