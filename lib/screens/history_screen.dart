import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/history/expense_history_list.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _categories = [
    _Category(label: '食費', icon: Icons.restaurant),
    _Category(label: '交際費', icon: Icons.people),
    _Category(label: '交通費', icon: Icons.directions_bus),
    _Category(label: '衣料品', icon: Icons.checkroom),
    _Category(label: '雑費', icon: Icons.category),
  ];

  String _formatYen(int amount) {
    final isNegative = amount < 0;
    final absText = amount.abs().toString();
    final withCommas = absText.replaceAllMapped(
      RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'),
      (m) => '${m[1]},',
    );
    return '${isNegative ? '-' : ''}¥$withCommas';
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$y/$m/$d $h:$min';
  }

  List<Expense> _filterByRange(List<Expense> expenses, _Range range) {
    final now = DateTime.now();
    switch (range) {
      case _Range.day:
        return expenses
            .where((e) =>
                e.createdAt.year == now.year &&
                e.createdAt.month == now.month &&
                e.createdAt.day == now.day)
            .toList();
      case _Range.week:
        final start = now.subtract(const Duration(days: 6));
        final startDate = DateTime(start.year, start.month, start.day);
        return expenses.where((e) => !e.createdAt.isBefore(startDate)).toList();
      case _Range.month:
        return expenses
            .where(
              (e) =>
                  e.createdAt.year == now.year &&
                  e.createdAt.month == now.month,
            )
            .toList();
    }
  }

  Map<String, int> _sumByCategory(List<Expense> expenses) {
    final map = {for (final c in _categories) c.label: 0};
    for (final e in expenses) {
      if (map.containsKey(e.category)) {
        map[e.category] = map[e.category]! + e.amount;
      } else {
        map['雑費'] = (map['雑費'] ?? 0) + e.amount;
      }
    }
    return map;
  }

  void _openCategoryHistory(
    BuildContext context, {
    required String category,
    required List<Expense> allExpenses,
  }) {
    final filtered = allExpenses.where((e) => e.category == category).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CategoryHistoryScreen(
          title: '$categoryの履歴',
          expenses: filtered,
          formatDate: _formatDate,
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String label,
    required IconData icon,
    required int amount,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.indigo.shade50,
                child: Icon(icon, color: Colors.indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _formatYen(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required BuildContext context,
    required List<Expense> periodExpenses,
    required List<Expense> allExpenses,
  }) {
    final sums = _sumByCategory(periodExpenses);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final cat = _categories[index];
        return _buildCategoryCard(
          label: cat.label,
          icon: cat.icon,
          amount: sums[cat.label] ?? 0,
          onTap: () => _openCategoryHistory(
            context,
            category: cat.label,
            allExpenses: allExpenses,
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: _categories.length,
    );
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: TabBar(
                labelColor: Colors.indigo,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.indigo,
                tabs: const [
                  Tab(text: '日'),
                  Tab(text: '週'),
                  Tab(text: '月'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(
              context: context,
              periodExpenses: _filterByRange(expenses, _Range.day),
              allExpenses: expenses,
            ),
            _buildTabContent(
              context: context,
              periodExpenses: _filterByRange(expenses, _Range.week),
              allExpenses: expenses,
            ),
            _buildTabContent(
              context: context,
              periodExpenses: _filterByRange(expenses, _Range.month),
              allExpenses: expenses,
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  const _Category({required this.label, required this.icon});
}

enum _Range { day, week, month }

class _CategoryHistoryScreen extends StatelessWidget {
  const _CategoryHistoryScreen({
    required this.title,
    required this.expenses,
    required this.formatDate,
  });

  final String title;
  final List<Expense> expenses;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: expenses.isEmpty
          ? const Center(child: Text('このカテゴリの履歴はありません'))
          : ExpenseHistoryList(
              expenses: expenses,
              formatDate: formatDate,
            ),
    );
  }
}
