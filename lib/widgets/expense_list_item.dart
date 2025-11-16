import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.formattedDate,
  });

  final Expense expense;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '¥ ${expense.amount}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${expense.category} / $formattedDate',
            style: const TextStyle(fontSize: 12),
          ),
          if (expense.memo != null && expense.memo!.isNotEmpty)
            Text(
              expense.memo!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}