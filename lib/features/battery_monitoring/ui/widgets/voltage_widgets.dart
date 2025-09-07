import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dimension.dart';
import '../../../../core/constant/app_string.dart';


class VoltageGaugeWidget extends StatelessWidget {
  final double voltage;

  const VoltageGaugeWidget({
    Key? key,
    required this.voltage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.voltage,
            style: TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          SizedBox(
            height: AppDimensions.gaugeSizeLarge,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 12,
                  showAxisLine: false,
                  showLabels: false,
                  showTicks: false,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: voltage,
                      color: AppColors.voltageGauge,
                      startWidth: AppDimensions.gaugeRangeWidthLarge,
                      endWidth: AppDimensions.gaugeRangeWidthLarge,
                    ),
                    GaugeRange(
                      startValue: voltage,
                      endValue: 12,
                      color: AppColors.inactiveGauge,
                      startWidth: AppDimensions.gaugeRangeWidthLarge,
                      endWidth: AppDimensions.gaugeRangeWidthLarge,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    MarkerPointer(
                      value: voltage,
                      markerHeight: AppDimensions.gaugePointerSizeLarge,
                      markerWidth: AppDimensions.gaugePointerSizeLarge,
                      markerType: MarkerType.circle,
                      color: AppColors.voltageGauge,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${voltage.toStringAsFixed(2)}V',
                            style: TextStyle(
                              fontSize: AppDimensions.fontSizeTitle,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            AppStrings.volts,
                            style: TextStyle(
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}