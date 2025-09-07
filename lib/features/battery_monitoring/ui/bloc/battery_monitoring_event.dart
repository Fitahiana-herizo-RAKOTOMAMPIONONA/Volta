import 'package:equatable/equatable.dart';

abstract class BatteryMonitoringEvent extends Equatable {
  const BatteryMonitoringEvent();

  @override
  List<Object> get props => [];
}

class InitialBatteryCheck extends BatteryMonitoringEvent {}

class StartMonitoringEvent extends BatteryMonitoringEvent {}

class StopMonitoringEvent extends BatteryMonitoringEvent {}

class ResetMeasurementsEvent extends BatteryMonitoringEvent {}

class BatteryStatsUpdated extends BatteryMonitoringEvent {
  final double voltage;
  final double current;
  final double power;
  final bool isCharging;

  const BatteryStatsUpdated({
    required this.voltage,
    required this.current,
    required this.power,
    required this.isCharging,
  });

  @override
  List<Object> get props => [voltage, current, power, isCharging];
}
