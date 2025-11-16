import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../expense_list_item.dart';

class ExpenseHistoryList extends StatelessWidget {
  const ExpenseHistoryList({
    super.key,
    required this.expenses,
    required this.formatDate,
  });

  final List<Expense> expenses;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];

        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.endToStart, // 右→左スワイプで削除
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.redAccent,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) {
            // Provider 経由で削除＆永続化
            context.read<ExpenseProvider>().removeExpense(expense.id);

            // ちょっとしたフィードバック
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('¥${expense.amount} を削除しました'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: ExpenseListItem(
            expense: expense,
            formattedDate: formatDate(expense.createdAt),
          ),
        );
      },
    );
  }
}