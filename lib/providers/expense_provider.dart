import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  ExpenseCategory? _selectedCategory;
  String _searchQuery = '';

  ExpenseProvider({ExpenseRepository? repository})
      : _repository = repository ?? ExpenseRepository();

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  ExpenseCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Filtered list based on search and category
  List<Expense> get filteredExpenses {
    return _expenses.where((exp) {
      final matchesCategory = _selectedCategory == null ||
          exp.category == _selectedCategory;
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          exp.title.toLowerCase().contains(q) ||
          exp.merchant.toLowerCase().contains(q) ||
          (exp.notes?.toLowerCase().contains(q) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Total spending across all transactions
  double get totalSpending =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  /// Total spending in the current month
  double get thisMonthSpending {
    final now = DateTime.now();
    return _expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Today's spending
  double get todaySpending {
    final now = DateTime.now();
    return _expenses.where((e) {
      return e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Category breakdown: Total amount per category
  Map<ExpenseCategory, double> get categoryTotals {
    final Map<ExpenseCategory, double> totals = {
      for (final cat in ExpenseCategory.values) cat: 0.0,
    };
    for (final exp in _expenses) {
      totals[exp.category] = (totals[exp.category] ?? 0.0) + exp.amount;
    }
    return totals;
  }

  /// Category percentages
  Map<ExpenseCategory, double> get categoryPercentages {
    final total = totalSpending;
    if (total == 0) {
      return {for (final cat in ExpenseCategory.values) cat: 0.0};
    }
    final totals = categoryTotals;
    return totals.map((cat, amount) => MapEntry(cat, (amount / total) * 100));
  }

  /// Weekly spending: Amounts for Monday to Sunday of the current week (7 elements)
  List<double> get weeklyDayTotals {
    final now = DateTime.now();
    // Monday = 1, Sunday = 7
    final currentWeekday = now.weekday;
    final monday = now.subtract(Duration(days: currentWeekday - 1));
    final startOfMonday = DateTime(monday.year, monday.month, monday.day);

    final dayTotals = List<double>.filled(7, 0.0);

    for (final exp in _expenses) {
      final expDay = DateTime(exp.date.year, exp.date.month, exp.date.day);
      final diff = expDay.difference(startOfMonday).inDays;
      if (diff >= 0 && diff < 7) {
        dayTotals[diff] += exp.amount;
      }
    }

    return dayTotals;
  }

  /// Load data from repository
  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    await _repository.initialize();
    _expenses = await _repository.getAllExpenses();

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new expense
  Future<void> addExpense(Expense expense) async {
    await _repository.insertExpense(expense);
    _expenses.insert(0, expense);
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Filter operations
  void setCategoryFilter(ExpenseCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Reset data to initial mock seed
  Future<void> resetToSeedData() async {
    _isLoading = true;
    notifyListeners();

    await _repository.clearAll();
    await _repository.seedInitialData();
    _expenses = await _repository.getAllExpenses();

    _isLoading = false;
    notifyListeners();
  }
}
