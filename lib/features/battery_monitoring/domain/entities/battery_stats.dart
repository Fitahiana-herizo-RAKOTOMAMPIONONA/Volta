import 'package:equatable/equatable.dart';

class BatteryStats extends Equatable {
  final double voltage;
  final double current;
  final double power;
  final bool isCharging;

  const BatteryStats({
    required this.voltage,
    required this.current,
    required this.power,
    required this.isCharging,
  });

  @override
  List<Object> get props => [voltage, current, power, isCharging];
}
