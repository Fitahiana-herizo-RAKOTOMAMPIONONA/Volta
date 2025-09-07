import '../../domain/entities/battery_stats.dart';

class BatteryStatsModel extends BatteryStats {
  const BatteryStatsModel({
    required super.voltage,
    required super.current,
    required super.power,
    required super.isCharging,
  });

  factory BatteryStatsModel.fromMap(Map<String, dynamic> map) {
    return BatteryStatsModel(
      voltage: (map['voltage'] ?? 0).toDouble(),
      current: (map['current'] ?? 0).toDouble(),
      power: (map['power'] ?? 0).toDouble(),
      isCharging: map['isCharging'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'voltage': voltage,
      'current': current,
      'power': power,
      'isCharging': isCharging,
    };
  }
}