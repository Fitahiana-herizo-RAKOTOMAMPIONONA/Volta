import 'package:equatable/equatable.dart';
import '../../domain/entities/charging_statics.dart';
import '../../domain/entities/power_measurement.dart';

enum MonitoringStatus { initial, monitoring, stopped }

class BatteryMonitoringState extends Equatable {
  final double voltage;
  final double current;
  final double power;
  final bool isCharging;
  final MonitoringStatus status;
  final List<PowerMeasurement> measurements;
  final ChargingStatistics statistics;
  final String? errorMessage;
  final bool isLoading;

  const BatteryMonitoringState({
    this.voltage = 0.0,
    this.current = 0.0,
    this.power = 0.0,
    this.isCharging = false,
    this.status = MonitoringStatus.initial,
    this.measurements = const [],
    this.statistics = const ChargingStatistics(
      maxPower: 0.0,
      avgPower: 0.0,
      maxVoltage: 0.0,
      maxCurrent: 0.0,
      measurementCount: 0,
    ),
    this.errorMessage,
    this.isLoading = false,
  });

  BatteryMonitoringState copyWith({
    double? voltage,
    double? current,
    double? power,
    bool? isCharging,
    MonitoringStatus? status,
    List<PowerMeasurement>? measurements,
    ChargingStatistics? statistics,
    String? errorMessage,
    bool? isLoading,
  }) {
    return BatteryMonitoringState(
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      power: power ?? this.power,
      isCharging: isCharging ?? this.isCharging,
      status: status ?? this.status,
      measurements: measurements ?? this.measurements,
      statistics: statistics ?? this.statistics,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isMonitoring => status == MonitoringStatus.monitoring;
  bool get hasMeasurements => measurements.isNotEmpty;

  @override
  List<Object?> get props => [
        voltage,
        current,
        power,
        isCharging,
        status,
        measurements,
        statistics,
        errorMessage,
        isLoading,
      ];
}
