import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dimension.dart';
import '../../../../core/constant/app_string.dart';


class CurrentGaugeWidget extends StatelessWidget {
  final double current;

  const CurrentGaugeWidget({
    Key? key,
    required this.current,
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
            AppStrings.current,
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
                  maximum: 3,
                  showAxisLine: false,
                  showLabels: false,
                  showTicks: false,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: current,
                      color: AppColors.currentGauge,
                      startWidth: AppDimensions.gaugeRangeWidthSmall,
                      endWidth: AppDimensions.gaugeRangeWidthSmall,
                    ),
                    GaugeRange(
                      startValue: current,
                      endValue: 3,
                      color: AppColors.inactiveGauge,
                      startWidth: AppDimensions.gaugeRangeWidthSmall,
                      endWidth: AppDimensions.gaugeRangeWidthSmall,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    MarkerPointer(
                      value: current,
                      markerHeight: AppDimensions.gaugePointerSizeSmall,
                      markerWidth: AppDimensions.gaugePointerSizeSmall,
                      markerType: MarkerType.circle,
                      color: AppColors.currentGauge,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${current.toStringAsFixed(2)}A',
                            style: TextStyle(
                              fontSize: AppDimensions.fontSizeExtraLarge,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            AppStrings.amperes,
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