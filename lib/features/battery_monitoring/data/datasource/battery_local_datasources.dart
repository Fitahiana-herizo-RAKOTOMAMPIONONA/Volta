import '../../../../core/errors/exception.dart';
import '../../../../core/platform/platform_channel.dart';
import '../models/battery_stats.models.dart';

abstract class BatteryLocalDataSource {
  Future<BatteryStatsModel> getBatteryStats();
}

class BatteryLocalDataSourceImpl implements BatteryLocalDataSource {
  @override
  Future<BatteryStatsModel> getBatteryStats() async {
    final result = await PlatformChannel.getBatteryStats();
    
    if (result != null) {
      return BatteryStatsModel.fromMap(result);
    } else {
      throw CacheException();
    }
  }
}