import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final int amount;
  final DateTime dateTime;
  final String category;
  final String memo;

  Expense({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.category,
    required this.memo,
  });

  // 工場メソッド：新規作成時に自動でUUIDを生成
  factory Expense.create({
    required int amount,
    required String category,
    String memo = '',
  }) {
    const uuid = Uuid();
    return Expense(
      id: uuid.v4(),
      amount: amount,
      dateTime: DateTime.now(),
      category: category,
      memo: memo,
    );
  }
}