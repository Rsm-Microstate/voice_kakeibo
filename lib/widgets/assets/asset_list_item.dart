// lib/widgets/assets/asset_list_item.dart
import 'package:flutter/material.dart';
import '../../models/asset.dart';

class AssetListItem extends StatelessWidget {
  final Asset asset;

  const AssetListItem({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(asset.name),
        trailing: Text(
          '¥ ${asset.amount}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}