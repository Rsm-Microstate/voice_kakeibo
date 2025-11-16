// lib/models/assets.dart
class Asset {
  final String id;
  final String name;
  final int amount; // 円単位

  const Asset({
    required this.id,
    required this.name,
    required this.amount,
  });

  Asset copyWith({
    String? id,
    String? name,
    int? amount,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as int,
    );
  }
}