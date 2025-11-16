// lib/providers/expense_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  static const _storageKey = 'expenses_v1';

  final List<Expense> _items = [];

    /// 履歴表示などで使う読み取り専用リスト
  List<Expense> get allExpenses => List.unmodifiable(_items);

  /// 互換用エイリアス（昔のコードで provider.expenses を使っている箇所向け）
  List<Expense> get expenses => List.unmodifiable(_items);

  /// アプリ起動時などに呼び出して、保存済みデータを読み込む
  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;

    try {
      final List decoded = jsonDecode(jsonString) as List;
      _items
        ..clear()
        ..addAll(
          decoded.map(
            (e) => Expense.fromJson(e as Map<String, dynamic>),
          ),
        );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load expenses: $e');
      }
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _items.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  /// 支出追加
  Future<void> addExpense(Expense expense) async {
    _items.insert(0, expense); // 新しいものを上に
    notifyListeners();
    await _saveExpenses();
  }

  /// 支出削除（スワイプ削除などで使用）
  Future<void> removeExpense(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _saveExpenses();
  }

  /// 今日の合計
  int getTodayTotal() {
    final now = DateTime.now();
    return _items
        .where(
          (e) =>
              e.createdAt.year == now.year &&
              e.createdAt.month == now.month &&
              e.createdAt.day == now.day,
        )
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// 今月の合計
  int getMonthTotal() {
    final now = DateTime.now();
    return _items
        .where(
          (e) =>
              e.createdAt.year == now.year &&
              e.createdAt.month == now.month,
        )
        .fold(0, (sum, e) => sum + e.amount);
  }
}