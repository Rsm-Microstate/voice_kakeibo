import 'package:flutter/foundation.dart';
import '../models/asset.dart';

class AssetProvider extends ChangeNotifier {
  // 初期値（後で書き換えるので const リストにはしない）
  final List<Asset> _assets = [
    const Asset(id: 'cash', name: '現金', amount: 50000),
    const Asset(id: 'bank', name: '銀行口座', amount: 120000),
    const Asset(id: 'points', name: 'ポイント', amount: 2000),
  ];

  /// 一覧取得（外側からは読み取り専用）
  List<Asset> get assets => List.unmodifiable(_assets);

  /// 総資産額
  int get totalAssets =>
      _assets.fold<int>(0, (sum, asset) => sum + asset.amount);

  /// 金額の更新
  void updateAssetAmount(String id, int newAmount) {
    final index = _assets.indexWhere((asset) => asset.id == id);
    if (index == -1) return;

    _assets[index] = _assets[index].copyWith(amount: newAmount);
    notifyListeners();
  }
}
