import 'package:flutter/foundation.dart';
import '../models/asset.dart';

class AssetProvider extends ChangeNotifier {
  // 初期値（後で書き換えるので const リストにはしない）
  final List<Asset> _assets = [
    const Asset(id: 'cash', name: '現金', amount: 50000),
    const Asset(id: 'bank', name: '銀行口座', amount: 120000),
    const Asset(id: 'points', name: 'ポイント', amount: 2000),
  ];

  final List<AssetSnapshot> _dailyHistory = const [
    AssetSnapshot(label: '12/01', total: 165000),
    AssetSnapshot(label: '12/02', total: 164200),
    AssetSnapshot(label: '12/03', total: 163800),
    AssetSnapshot(label: '12/04', total: 164500),
    AssetSnapshot(label: '12/05', total: 163400),
    AssetSnapshot(label: '12/06', total: 162900),
    AssetSnapshot(label: '12/07', total: 162000),
  ];


  final List<AssetSnapshot> _history = const [
    AssetSnapshot(label: '6月', total: 180000),
    AssetSnapshot(label: '7月', total: 182000),
    AssetSnapshot(label: '8月', total: 176500),
    AssetSnapshot(label: '9月', total: 174000),
    AssetSnapshot(label: '10月', total: 168000),
    AssetSnapshot(label: '11月', total: 165000),
    AssetSnapshot(label: '12月', total: 162000),
  ];

  /// 一覧取得（外側からは読み取り専用）
  List<Asset> get assets => List.unmodifiable(_assets);

  /// 総資産額
  int get totalAssets =>
      _assets.fold<int>(0, (sum, asset) => sum + asset.amount);

  /// 日次の総資産推移
  List<AssetSnapshot> get dailyHistory => List.unmodifiable(_dailyHistory);

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
  final String label;
  final int total;

  const AssetSnapshot({
    required this.label,
    required this.total,
  });
}
