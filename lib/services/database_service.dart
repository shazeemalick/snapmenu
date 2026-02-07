import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_menu/models/menu_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database?> get database async {
    if (kIsWeb) return null; // SQLite NOT supported on web out of the box
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'easy_menu.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        results_json TEXT NOT NULL,
        scanned_at TEXT NOT NULL
      )
    ''');
  }

  // User Operations (Using SharedPreferences for better cross-platform support)
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  // Scan Operations
  Future<void> saveScan(String imagePath, List<MenuItem> items) async {
    if (kIsWeb) return; // History not supported on web yet
    final db = await database;
    if (db == null) return;
    
    await db.insert(
      'scans',
      {
        'image_path': imagePath,
        'results_json': jsonEncode(items.map((e) => e.toJson()).toList()),
        'scanned_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getScans() async {
    if (kIsWeb) return [];
    final db = await database;
    if (db == null) return [];
    
    return await db.query('scans', orderBy: 'scanned_at DESC');
  }

  Future<void> deleteScan(int id) async {
    if (kIsWeb) return;
    final db = await database;
    if (db == null) return;
    
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }
}
