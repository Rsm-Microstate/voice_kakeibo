// lib/widgets/assets/assets_summary_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/asset_provider.dart';

class AssetsSummaryCard extends StatelessWidget {
  const AssetsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AssetProvider>(context);
    final total = provider.totalAmount;
    final assets = provider.assets;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '総資産',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¥ $total',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 簡易レジェンド（将来ここを円グラフ＋凡例に差し替え）
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final asset in assets)
                  _LegendChip(
                    label: asset.name,
                    // 割合は小数点1桁で表示
                    percent: total == 0
                        ? 0
                        : (asset.amount * 100 / total).round(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final int percent;

  const _LegendChip({
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label：$percent%'),
    );
  }
}