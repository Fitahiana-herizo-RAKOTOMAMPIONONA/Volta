import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/battery_stats.dart';
import '../../domain/repositories/battery_repository.dart';
import '../datasource/battery_local_datasources.dart';

class BatteryRepositoryImpl implements BatteryRepository {
  final BatteryLocalDataSource localDataSource;
  Timer? _monitoringTimer;
  StreamController<Either<Failure, BatteryStats>>? _streamController;

  BatteryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, BatteryStats>> getBatteryStats() async {
    try {
      final batteryStats = await localDataSource.getBatteryStats();
      return Right(batteryStats);
    } on PlatformException catch (e) {
      return Left(PlatformFailure(e.message));
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Stream<Either<Failure, BatteryStats>> monitorBatteryStats() {
    _streamController = StreamController<Either<Failure, BatteryStats>>();
    
    _monitoringTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) async {
        final result = await getBatteryStats();
        _streamController?.add(result);
      },
    );

    return _streamController!.stream;
  }

  void dispose() {
    _monitoringTimer?.cancel();
    _streamController?.close();
  }
}