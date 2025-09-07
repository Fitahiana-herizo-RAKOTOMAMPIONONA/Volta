import 'package:equatable/equatable.dart';

class ChargingStatistics extends Equatable {
  final double maxPower;
  final double avgPower;
  final double maxVoltage;
  final double maxCurrent;
  final int measurementCount;

  const ChargingStatistics({
    required this.maxPower,
    required this.avgPower,
    required this.maxVoltage,
    required this.maxCurrent,
    required this.measurementCount,
  });

  @override
  List<Object> get props => [
    maxPower,
    avgPower,
    maxVoltage,
    maxCurrent,
    measurementCount,
  ];

  factory ChargingStatistics.empty() {
    return const ChargingStatistics(
      maxPower: 0.0,
      avgPower: 0.0,
      maxVoltage: 0.0,
      maxCurrent: 0.0,
      measurementCount: 0,
    );
  }
}