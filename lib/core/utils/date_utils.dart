class DateUtils {
  static String formatTimestamp(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
  
  static bool isRecentMeasurement(DateTime timestamp, Duration maxAge) {
    return DateTime.now().difference(timestamp) <= maxAge;
  }
}