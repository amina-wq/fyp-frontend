class InventoryStatsModel {
  final int expiredCount;
  final int expiringTomorrowCount;
  final int expiringInFiveDaysCount;
  final int freshCount;

  const InventoryStatsModel({
    required this.expiredCount,
    required this.expiringTomorrowCount,
    required this.expiringInFiveDaysCount,
    required this.freshCount,
  });

  factory InventoryStatsModel.fromJson(Map<String, dynamic> json) {
    return InventoryStatsModel(
      expiredCount: json['expired_count'] as int,
      expiringTomorrowCount: json['expiring_tomorrow_count'] as int,
      expiringInFiveDaysCount: json['expiring_in_5_days_count'] as int,
      freshCount: json['fresh_count'] as int,
    );
  }
}