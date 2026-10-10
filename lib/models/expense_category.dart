import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  study,
  travel,
  gear,
  entertainment;

  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.study:
        return 'Study & Books';
      case ExpenseCategory.travel:
        return 'Travel & Fuel';
      case ExpenseCategory.gear:
        return 'Gear & Tools';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
    }
  }

  String get viName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Ăn uống';
      case ExpenseCategory.study:
        return 'Học tập & Sách';
      case ExpenseCategory.travel:
        return 'Đi lại & Xăng xe';
      case ExpenseCategory.gear:
        return 'Thiết bị & Đồ dùng';
      case ExpenseCategory.entertainment:
        return 'Giải trí & Phim ảnh';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.study:
        return Icons.menu_book_rounded;
      case ExpenseCategory.travel:
        return Icons.directions_car_rounded;
      case ExpenseCategory.gear:
        return Icons.devices_other_rounded;
      case ExpenseCategory.entertainment:
        return Icons.sports_esports_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFFF7043); // Warm Deep Orange
      case ExpenseCategory.study:
        return const Color(0xFF3F51B5); // Indigo
      case ExpenseCategory.travel:
        return const Color(0xFF00897B); // Teal / Emerald
      case ExpenseCategory.gear:
        return const Color(0xFF7E57C2); // Deep Purple
      case ExpenseCategory.entertainment:
        return const Color(0xFFEC407A); // Pink / Rose
    }
  }

  static ExpenseCategory fromString(String? value) {
    if (value == null) return ExpenseCategory.food;
    final lower = value.toLowerCase().trim();
    for (final cat in ExpenseCategory.values) {
      if (cat.name == lower ||
          cat.displayName.toLowerCase() == lower ||
          cat.viName.toLowerCase() == lower) {
        return cat;
      }
    }
    return ExpenseCategory.food;
  }
}
