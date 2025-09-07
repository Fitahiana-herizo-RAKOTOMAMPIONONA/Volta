import 'package:flutter/material.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dimension.dart';
import '../../../../core/constant/app_string.dart';
import '../../domain/entities/charging_statics.dart';

class StatisticsCard extends StatelessWidget {
  final ChargingStatistics statistics;

  const StatisticsCard({
    Key? key,
    required this.statistics,
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.8,
            mainAxisSpacing: AppDimensions.paddingMedium,
            crossAxisSpacing: AppDimensions.paddingMedium,
            children: [
              _buildStatItem(
                AppStrings.maxPower,
                '${statistics.maxPower.toStringAsFixed(1)}W',
                Icons.offline_bolt,
                AppColors.powerSlow,
                textColor,
              ),
              _buildStatItem(
                AppStrings.avgPower,
                '${statistics.avgPower.toStringAsFixed(1)}W',
                Icons.show_chart,
                AppColors.powerFast,
                textColor,
              ),
              _buildStatItem(
                AppStrings.maxVoltage,
                '${statistics.maxVoltage.toStringAsFixed(1)}V',
                Icons.flash_on,
                AppColors.voltageGauge,
                textColor,
              ),
              _buildStatItem(
                AppStrings.maxCurrent,
                '${statistics.maxCurrent.toStringAsFixed(1)}A',
                Icons.electric_bolt,
                AppColors.powerVerySlow,
                textColor,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
            ),
            child: Text(
              '${statistics.measurementCount} ${AppStrings.measurementsCollected}',
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: AppDimensions.fontSizeMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconSizeSmall),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: AppDimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.fontSizeMedium,
              color: textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
