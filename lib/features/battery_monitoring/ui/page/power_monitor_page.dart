// lib/features/battery_monitoring/presentation/pages/power_monitor_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dimension.dart';
import '../../../../core/constant/app_string.dart';
import '../bloc/batter_monitoring_state.dart';
import '../bloc/battery_monitoring_bloc.dart';
import '../bloc/battery_monitoring_event.dart';
import '../widgets/action_button.dart';
import '../widgets/battery_status_card.dart';
import '../widgets/current_jauge_widget.dart';
import '../widgets/power_jauge_widget.dart';
import '../widgets/statistics_card.dart';
import '../widgets/voltage_widgets.dart';

class PowerMonitorPage extends StatelessWidget {
  const PowerMonitorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return BlocListener<BatteryMonitoringBloc, BatteryMonitoringState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          leading: IconButton(onPressed: (){}, icon: const Icon(Icons.menu)),
          title: const Text(
            AppStrings.powerTestTitle,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: textColor,
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.refresh),
          //     onPressed: () {
          //       context
          //           .read<BatteryMonitoringBloc>()
          //           .add(ResetMeasurementsEvent());
          //     },
          //   ),
          // ],
        ),
        body: SafeArea(
          child: BlocBuilder<BatteryMonitoringBloc, BatteryMonitoringState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Battery Status Card
                    BatteryStatusCard(
                      isCharging: state.isCharging,
                      power: state.power,
                    ),

                    const SizedBox(height: AppDimensions.paddingExtraLarge),

                   //si charging
                    if (state.isCharging) ...[
                      Text(
                        AppStrings.realTimeMeasurements,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeExtraLarge,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      VoltageGaugeWidget(voltage: state.voltage),

                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Current and Power Row
                      Row(
                        children: [
                          Expanded(
                            child: CurrentGaugeWidget(current: state.current),
                          ),
                          const SizedBox(width: AppDimensions.paddingMedium),
                          Expanded(
                            child: PowerGaugeWidget(power: state.power),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.paddingExtraLarge),

                      // Statistics
                      if (state.hasMeasurements) ...[
                        Text(
                          AppStrings.statistics,
                          style: TextStyle(
                            fontSize: AppDimensions.fontSizeExtraLarge,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        StatisticsCard(statistics: state.statistics),
                      ],
                    ],

                    const SizedBox(height: AppDimensions.paddingExtraLarge),

                    // Action Buttons
                    ActionButtons(
                      isCharging: state.isCharging,
                      isMonitoring: state.isMonitoring,
                      onStart: () {
                        context
                            .read<BatteryMonitoringBloc>()
                            .add(StartMonitoringEvent());
                      },
                      onStop: () {
                        context
                            .read<BatteryMonitoringBloc>()
                            .add(StopMonitoringEvent());
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
