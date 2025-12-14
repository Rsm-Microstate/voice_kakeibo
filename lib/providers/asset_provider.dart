import 'package:flutter/foundation.dart';
import '../models/asset.dart';

class AssetProvider extends ChangeNotifier {
  // 初期値（後で書き換えるので const リストにはしない）
  final List<Asset> _assets = [
    const Asset(id: 'cash', name: '現金', amount: 50000),
    const Asset(id: 'bank', name: '銀行口座', amount: 120000),
    const Asset(id: 'points', name: 'ポイント', amount: 2000),
  ];

  final List<AssetSnapshot> _history = const [
    AssetSnapshot(month: '6月', total: 180000),
    AssetSnapshot(month: '7月', total: 182000),
    AssetSnapshot(month: '8月', total: 176500),
    AssetSnapshot(month: '9月', total: 174000),
    AssetSnapshot(month: '10月', total: 168000),
    AssetSnapshot(month: '11月', total: 165000),
    AssetSnapshot(month: '12月', total: 162000),
  ];

  /// 一覧取得（外側からは読み取り専用）
  List<Asset> get assets => List.unmodifiable(_assets);

  /// 総資産額
  int get totalAssets =>
      _assets.fold<int>(0, (sum, asset) => sum + asset.amount);

  /// 月次の総資産推移
  List<AssetSnapshot> get monthlyHistory => List.unmodifiable(_history);

  /// 金額の更新
  void updateAssetAmount(String id, int newAmount) {
    final index = _assets.indexWhere((asset) => asset.id == id);
    if (index == -1) return;

    _assets[index] = _assets[index].copyWith(amount: newAmount);
    notifyListeners();
  }
  
  /// 指定アセットから支出分を減算する（下回る場合は0まで）
  void decreaseAsset(String id, int amount) {
    final index = _assets.indexWhere((asset) => asset.id == id);
    if (index == -1) return;

    final current = _assets[index].amount;
    final next = current - amount;
    _assets[index] = _assets[index].copyWith(amount: next < 0 ? 0 : next);
    notifyListeners();
  }
}

class AssetSnapshot {
  final String month;
  final int total;

  const AssetSnapshot({
    required this.month,
    required this.total,
  });
}
