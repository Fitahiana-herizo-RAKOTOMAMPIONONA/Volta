import 'dart:math';

class MathUtils {
  static double calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  static double findMaximum(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce(max);
  }
  
  static double findMinimum(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce(min);
  }
  
  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    num mod = pow(10.0, decimalPlaces);
    return ((value * mod).round().toDouble() / mod);
  }
}