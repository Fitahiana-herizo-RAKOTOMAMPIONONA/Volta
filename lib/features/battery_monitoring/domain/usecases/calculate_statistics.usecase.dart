import '../entities/charging_statics.dart';
import '../entities/power_measurement.dart';
import '../../../../core/utils/math_utils.dart';

class CalculateStatistics {
  ChargingStatistics call(List<PowerMeasurement> measurements) {
    if (measurements.isEmpty) {
      return ChargingStatistics.empty();
    }

    final powerValues = measurements.map((m) => m.power).toList();
    final voltageValues = measurements.map((m) => m.voltage).toList();
    final currentValues = measurements.map((m) => m.current).toList();

    return ChargingStatistics(
      maxPower: MathUtils.findMaximum(powerValues),
      avgPower: MathUtils.calculateAverage(powerValues),
      maxVoltage: MathUtils.findMaximum(voltageValues),
      maxCurrent: MathUtils.findMaximum(currentValues),
      measurementCount: measurements.length,
    );
  }
}