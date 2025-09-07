import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/battery_stats.dart';
import '../repositories/battery_repository.dart';

class StartMonitoring {
  final BatteryRepository repository;

  StartMonitoring(this.repository);

  Stream<Either<Failure, BatteryStats>> call() {
    return repository.monitorBatteryStats();
  }
}