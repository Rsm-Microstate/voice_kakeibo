// lib/models/expense.dart
import 'package:uuid/uuid.dart';

class Expense {
  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.createdAt,
    this.memo,
  });

  final String id;
  final int amount;
  final String category;
  final DateTime createdAt;
  final String? memo;

  /// 画面から新規作成するとき用のファクトリ
  factory Expense.create({
    required int amount,
    required String category,
    String? memo,
  }) {
    return Expense(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      createdAt: DateTime.now(),
      memo: memo,
    );
  }

  /// 永続化用 JSON 変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON から復元
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: json['amount'] as int,
      category: json['category'] as String,
      memo: json['memo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}