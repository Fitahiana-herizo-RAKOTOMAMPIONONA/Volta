import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/battery_stats.dart';

abstract class BatteryRepository {
  Future<Either<Failure, BatteryStats>> getBatteryStats();
  Stream<Either<Failure, BatteryStats>> monitorBatteryStats();
}