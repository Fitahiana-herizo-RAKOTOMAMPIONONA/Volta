import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/battery_stats.dart';
import '../repositories/battery_repository.dart';

class GetBatteryStats {
  final BatteryRepository repository;

  GetBatteryStats(this.repository);

  Future<Either<Failure, BatteryStats>> call() async {
    return await repository.getBatteryStats();
  }
}