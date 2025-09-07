import 'package:equatable/equatable.dart';

class PowerMeasurement extends Equatable {
  final double voltage;
  final double current;
  final double power;
  final DateTime timestamp;

  const PowerMeasurement({
    required this.voltage,
    required this.current,
    required this.power,
    required this.timestamp,
  });

  @override
  List<Object> get props => [voltage, current, power, timestamp];
}