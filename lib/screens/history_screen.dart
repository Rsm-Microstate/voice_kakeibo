import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../widgets/history/expense_history_list.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');

    return '$y/$m/$d $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.expenses;

    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'まだ登録された支出がありません',
          textAlign: TextAlign.center,
        ),
      );
    }

    // 実際のリスト表示は専用ウィジェットに委譲
    return ExpenseHistoryList(
      expenses: expenses,
      formatDate: _formatDate,
    );
  }
}