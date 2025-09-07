import '../../domain/entities/power_measurement.dart';
import 'battery_stats.models.dart';

class PowerMeasurementModel extends PowerMeasurement {
  const PowerMeasurementModel({
    required super.voltage,
    required super.current,
    required super.power,
    required super.timestamp,
  });

  factory PowerMeasurementModel.fromBatteryStats(
    BatteryStatsModel stats,
    DateTime timestamp,
  ) {
    return PowerMeasurementModel(
      voltage: stats.voltage,
      current: stats.current,
      power: stats.power,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'voltage': voltage,
      'current': current,
      'power': power,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory PowerMeasurementModel.fromMap(Map<String, dynamic> map) {
    return PowerMeasurementModel(
      voltage: (map['voltage'] ?? 0).toDouble(),
      current: (map['current'] ?? 0).toDouble(),
      power: (map['power'] ?? 0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
