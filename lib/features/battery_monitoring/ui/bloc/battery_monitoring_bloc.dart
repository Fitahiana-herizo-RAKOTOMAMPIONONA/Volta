import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/charging_statics.dart';
import '../../domain/entities/power_measurement.dart';
import '../../domain/usecases/calculate_statistics.usecase.dart';
import '../../domain/usecases/get_battery.usecase.dart';
import '../../domain/usecases/start_monitoring.usecase.dart';
import 'batter_monitoring_state.dart';
import 'battery_monitoring_event.dart';

class BatteryMonitoringBloc extends Bloc<BatteryMonitoringEvent, BatteryMonitoringState> {
  final GetBatteryStats getBatteryStats;
  final StartMonitoring startMonitoring;
  final CalculateStatistics calculateStatistics;

  StreamSubscription? _monitoringSubscription;

  BatteryMonitoringBloc({
    required this.getBatteryStats,
    required this.startMonitoring,
    required this.calculateStatistics,
  }) : super(const BatteryMonitoringState()) {
    on<InitialBatteryCheck>(_onInitialBatteryCheck);
    on<StartMonitoringEvent>(_onStartMonitoring);
    on<StopMonitoringEvent>(_onStopMonitoring);
    on<ResetMeasurementsEvent>(_onResetMeasurements);
    on<BatteryStatsUpdated>(_onBatteryStatsUpdated);
  }

  Future<void> _onInitialBatteryCheck(
    InitialBatteryCheck event,
    Emitter<BatteryMonitoringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    final result = await getBatteryStats();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get battery stats',
      )),
      (batteryStats) => emit(state.copyWith(
        voltage: batteryStats.voltage,
        current: batteryStats.current,
        power: batteryStats.power,
        isCharging: batteryStats.isCharging,
        isLoading: false,
        errorMessage: null,
      )),
    );
  }

  void _onStartMonitoring(
    StartMonitoringEvent event,
    Emitter<BatteryMonitoringState> emit,
  ) {
    if (state.status == MonitoringStatus.monitoring) return;
    
    emit(state.copyWith(
      status: MonitoringStatus.monitoring,
      measurements: [],
      statistics: ChargingStatistics.empty(),
    ));

    _monitoringSubscription = startMonitoring().listen(
      (result) {
        result.fold(
          (failure) => add(BatteryStatsUpdated(
            voltage: 0,
            current: 0,
            power: 0,
            isCharging: false,
          )),
          (batteryStats) => add(BatteryStatsUpdated(
            voltage: batteryStats.voltage,
            current: batteryStats.current,
            power: batteryStats.power,
            isCharging: batteryStats.isCharging,
          )),
        );
      },
    );
  }

  void _onStopMonitoring(
    StopMonitoringEvent event,
    Emitter<BatteryMonitoringState> emit,
  ) {
    _monitoringSubscription?.cancel();
    emit(state.copyWith(status: MonitoringStatus.stopped));
  }

  void _onResetMeasurements(
    ResetMeasurementsEvent event,
    Emitter<BatteryMonitoringState> emit,
  ) {
    emit(state.copyWith(
      measurements: [],
      statistics: ChargingStatistics.empty(),
    ));
  }

  void _onBatteryStatsUpdated(
    BatteryStatsUpdated event,
    Emitter<BatteryMonitoringState> emit,
  ) {
    emit(state.copyWith(
      voltage: event.voltage,
      current: event.current,
      power: event.power,
      isCharging: event.isCharging,
    ));

    // If charging and monitoring, add measurement
    if (event.isCharging && state.isMonitoring) {
      final newMeasurement = PowerMeasurement(
        voltage: event.voltage,
        current: event.current,
        power: event.power,
        timestamp: DateTime.now(),
      );

      final updatedMeasurements = List<PowerMeasurement>.from(state.measurements)
        ..add(newMeasurement);

      // Keep only the last 100 measurements
      if (updatedMeasurements.length > 100) {
        updatedMeasurements.removeAt(0);
      }

      final newStatistics = calculateStatistics(updatedMeasurements);

      emit(state.copyWith(
        measurements: updatedMeasurements,
        statistics: newStatistics,
      ));
    }

    // Stop monitoring if not charging
    if (!event.isCharging && state.isMonitoring) {
      add(StopMonitoringEvent());
    }
  }

  @override
  Future<void> close() {
    _monitoringSubscription?.cancel();
    return super.close();
  }
}