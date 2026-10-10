import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sql;
import '../models/expense.dart';
import '../models/expense_category.dart';

class ExpenseRepository {
  static const String _tableName = 'expenses';
  static const String _dbName = 'expense_tracker.db';
  static const String _webPrefsKey = 'saved_expenses_json';
  static const String _seedFlagKey = 'has_seeded_initial_data_v1';

  sql.Database? _database;

  Future<sql.Database?> _getDatabase() async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;

    try {
      final dbPath = await sql.getDatabasesPath();
      final path = p.join(dbPath, _dbName);

      _database = await sql.openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              merchant TEXT NOT NULL,
              amount REAL NOT NULL,
              date TEXT NOT NULL,
              category TEXT NOT NULL,
              receiptImagePath TEXT,
              rawOcrText TEXT,
              notes TEXT,
              createdAt TEXT NOT NULL
            )
          ''');
        },
      );
      return _database;
    } catch (e) {
      debugPrint('Sqflite initialization error (fallback to SharedPreferences): $e');
      return null;
    }
  }

  /// Initialize and seed data if first time
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeeded = prefs.getBool(_seedFlagKey) ?? false;

    if (!hasSeeded) {
      await seedInitialData();
      await prefs.setBool(_seedFlagKey, true);
    }
  }

  /// Seed realistic student expenses for immediate demonstration
  Future<void> seedInitialData() async {
    final now = DateTime.now();

    final seedItems = [
      Expense(
        id: 'seed-1',
        title: 'Mua thực phẩm & đồ ăn sáng',
        merchant: 'WinMart+',
        amount: 154000,
        date: now.subtract(const Duration(hours: 4)),
        category: ExpenseCategory.food,
        notes: 'Bánh mì sandwich, sữa tươi Vinamilk, mì Hảo Hảo',
        rawOcrText: 'WINMART+ DA NANG\nTONG CONG: 154.000 VND\nNgay: 10/10/2026',
      ),
      Expense(
        id: 'seed-2',
        title: 'Học nhóm đồ án Flutter',
        merchant: 'Highlands Coffee',
        amount: 118000,
        date: now.subtract(const Duration(days: 1, hours: 2)),
        category: ExpenseCategory.food,
        notes: 'Phin sữa đá, Trà sen vàng, bánh ngọt',
        rawOcrText: 'HIGHLANDS COFFEE\nTong tien: 118.000 d\nThoi gian: 09/10/2026',
      ),
      Expense(
        id: 'seed-3',
        title: 'Giáo trình Lập trình di động',
        merchant: 'Nhà Sách Fahasa',
        amount: 235000,
        date: now.subtract(const Duration(days: 2, hours: 5)),
        category: ExpenseCategory.study,
        notes: 'Giáo trình Flutter, sổ tay ghi chú, bút bi Sarasa',
        rawOcrText: 'NHA SACH FAHASA\nKHACH PHAI TRA: 235.000 VND\nDate: 08/10/2026',
      ),
      Expense(
        id: 'seed-4',
        title: 'Đổ xăng xe máy đi học VKU',
        merchant: 'Petrolimex',
        amount: 90000,
        date: now.subtract(const Duration(days: 3, hours: 8)),
        category: ExpenseCategory.travel,
        notes: 'Xăng RON 95-III 4.12 lit',
        rawOcrText: 'PETROLIMEX\nTONG CONG: 90.000 VND\nNgay ban: 07/10/2026',
      ),
      Expense(
        id: 'seed-5',
        title: 'Chuột quang và cáp Type-C',
        merchant: 'Phong Vũ',
        amount: 320000,
        date: now.subtract(const Duration(days: 4, hours: 3)),
        category: ExpenseCategory.gear,
        notes: 'Logitech B100 + Cáp Baseus Type-C',
        rawOcrText: 'PHONG VU DA NANG\nTONG TIEN: 320.000 VND\nNgay: 06/10/2026',
      ),
      Expense(
        id: 'seed-6',
        title: 'Vé xem phim cuối tuần',
        merchant: 'CGV Cinemas',
        amount: 190000,
        date: now.subtract(const Duration(days: 5, hours: 6)),
        category: ExpenseCategory.entertainment,
        notes: 'Vé xem phim và combo bắp nước',
        rawOcrText: 'CGV CINEMAS\nTOTAL: 190.000 VND\nDate: 05/10/2026',
      ),
      Expense(
        id: 'seed-7',
        title: 'In tài liệu báo cáo đồ án VKU',
        merchant: 'Photo & In Ấn VKU',
        amount: 45000,
        date: now.subtract(const Duration(days: 6, hours: 1)),
        category: ExpenseCategory.study,
        notes: 'Đóng cuốn bìa kiếng báo cáo thực tập',
        rawOcrText: 'PHOTO IN AN VKU\nThanh toan: 45.000 d\nNgay: 04/10/2026',
      ),
    ];

    for (final exp in seedItems) {
      await insertExpense(exp);
    }
  }

  /// Retrieve all expenses sorted by date descending
  Future<List<Expense>> getAllExpenses() async {
    final db = await _getDatabase();

    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'date DESC',
      );
      return maps.map((m) => Expense.fromMap(m)).toList();
    } else {
      // SharedPreferences web / desktop fallback
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_webPrefsKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      try {
        final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
        final expenses = list
            .map((item) => Expense.fromMap(item as Map<String, dynamic>))
            .toList();
        expenses.sort((a, b) => b.date.compareTo(a.date));
        return expenses;
      } catch (e) {
        debugPrint('JSON decode error in getAllExpenses: $e');
        return [];
      }
    }
  }

  /// Insert a new expense
  Future<void> insertExpense(Expense expense) async {
    final db = await _getDatabase();

    if (db != null) {
      await db.insert(
        _tableName,
        expense.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getAllExpenses();
      currentList.removeWhere((item) => item.id == expense.id);
      currentList.insert(0, expense);

      final encoded = jsonEncode(currentList.map((e) => e.toMap()).toList());
      await prefs.setString(_webPrefsKey, encoded);
    }
  }

  /// Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    final db = await _getDatabase();

    if (db != null) {
      await db.update(
        _tableName,
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getAllExpenses();
      final index = currentList.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        currentList[index] = expense;
      } else {
        currentList.insert(0, expense);
      }
      final encoded = jsonEncode(currentList.map((e) => e.toMap()).toList());
      await prefs.setString(_webPrefsKey, encoded);
    }
  }

  /// Delete an expense by ID
  Future<void> deleteExpense(String id) async {
    final db = await _getDatabase();

    if (db != null) {
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getAllExpenses();
      currentList.removeWhere((e) => e.id == id);
      final encoded = jsonEncode(currentList.map((e) => e.toMap()).toList());
      await prefs.setString(_webPrefsKey, encoded);
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    final db = await _getDatabase();
    if (db != null) {
      await db.delete(_tableName);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webPrefsKey);
    }
  }
}
