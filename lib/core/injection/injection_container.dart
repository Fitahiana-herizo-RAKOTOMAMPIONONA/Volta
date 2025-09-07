import 'package:get_it/get_it.dart';
import '../../features/battery_monitoring/data/datasource/battery_local_datasources.dart';
import '../../features/battery_monitoring/data/repositories/battery_repository_impl.dart';
import '../../features/battery_monitoring/domain/repositories/battery_repository.dart';
import '../../features/battery_monitoring/domain/usecases/calculate_statistics.usecase.dart';
import '../../features/battery_monitoring/domain/usecases/get_battery.usecase.dart';
import '../../features/battery_monitoring/domain/usecases/start_monitoring.usecase.dart';
import '../../features/battery_monitoring/ui/bloc/battery_monitoring_bloc.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Features - Battery Monitoring
  // BLoC
  sl.registerFactory(
    () => BatteryMonitoringBloc(
      getBatteryStats: sl(),
      startMonitoring: sl(),
      calculateStatistics: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBatteryStats(sl()));
  sl.registerLazySingleton(() => StartMonitoring(sl()));
  sl.registerLazySingleton(() => CalculateStatistics());

  // Repository
  sl.registerLazySingleton<BatteryRepository>(
    () => BatteryRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BatteryLocalDataSource>(
    () => BatteryLocalDataSourceImpl(),
  );
}