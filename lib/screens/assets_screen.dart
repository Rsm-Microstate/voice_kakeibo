// lib/screens/assets_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/asset.dart';
import '../providers/asset_provider.dart';
import 'asset_history_screen.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetProvider>(
      builder: (context, assetProvider, _) {
        final total = assetProvider.totalAssets;
        final assets = assetProvider.assets;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F6FF),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Voice Kakeibo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 総資産カード（タップで推移グラフへ）
                  _TotalAssetsCard(
                    total: total,
                    onTap: () {
                      final history = assetProvider.monthlyHistory;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AssetHistoryScreen(history: history),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 資産リスト
                  Expanded(
                    child: ListView.separated(
                      itemCount: assets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        return _AssetRow(
                          asset: asset,
                          onTap: () => _showEditDialog(context, asset),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, Asset asset) async {
    final controller =
        TextEditingController(text: asset.amount.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${asset.name}の金額を編集'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '金額（円）',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                final value = int.tryParse(text);
                if (value == null || value < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('正しい金額を入力してください'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      // ダイアログで OK された値で更新
      context.read<AssetProvider>().updateAssetAmount(asset.id, result);
    }
  }
}

/// 総資産カード
class _TotalAssetsCard extends StatelessWidget {
  const _TotalAssetsCard({
    required this.total,
    required this.onTap,
  });

  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '総資産',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '¥ $total',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 資産1行分のカード
class _AssetRow extends StatelessWidget {
  const _AssetRow({
    required this.asset,
    required this.onTap,
  });

  final Asset asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                asset.name,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '¥ ${asset.amount}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
