import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dimension.dart';
import '../../../../core/constant/app_string.dart';


class PowerGaugeWidget extends StatelessWidget {
  final double power;

  const PowerGaugeWidget({
    Key? key,
    required this.power,
  }) : super(key: key);

  Color _getPowerColor(double power) {
    if (power < 5) return AppColors.powerVerySlow;
    if (power < 10) return AppColors.powerSlow;
    if (power < 15) return AppColors.powerNormal;
    if (power < 20) return AppColors.powerFast;
    return AppColors.powerUltraFast;
  }

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
            AppStrings.power,
            style: TextStyle(
              fontSize: AppDimensions.fontSizeRegular,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          SizedBox(
            height: AppDimensions.gaugeSizeSmall,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 25,
                  showAxisLine: false,
                  showLabels: false,
                  showTicks: false,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: power,
                      color: _getPowerColor(power),
                      startWidth: AppDimensions.gaugeRangeWidthSmall,
                      endWidth: AppDimensions.gaugeRangeWidthSmall,
                    ),
                    GaugeRange(
                      startValue: power,
                      endValue: 25,
                      color: AppColors.inactiveGauge,
                      startWidth: AppDimensions.gaugeRangeWidthSmall,
                      endWidth: AppDimensions.gaugeRangeWidthSmall,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    MarkerPointer(
                      value: power,
                      markerHeight: AppDimensions.gaugePointerSizeSmall,
                      markerWidth: AppDimensions.gaugePointerSizeSmall,
                      markerType: MarkerType.circle,
                      color: _getPowerColor(power),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${power.toStringAsFixed(1)}W',
                            style: TextStyle(
                              fontSize: AppDimensions.fontSizeExtraLarge,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            AppStrings.watts,
                            style: TextStyle(
                              fontSize: AppDimensions.fontSizeSmall,
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
