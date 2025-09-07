import 'package:flutter/material.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dimension.dart';
import '../../../../core/constant/app_string.dart' show AppStrings;

class BatteryStatusCard extends StatelessWidget {
  final bool isCharging;
  final double power;

  const BatteryStatusCard({
    Key? key,
    required this.isCharging,
    required this.power,
  }) : super(key: key);

  Color _getPowerColor(double power) {
    if (power < 5) return AppColors.powerVerySlow;
    if (power < 10) return AppColors.powerSlow;
    if (power < 15) return AppColors.powerNormal;
    if (power < 20) return AppColors.powerFast;
    return AppColors.powerUltraFast;
  }

  String _getChargingQuality(double power) {
    if (power < 5) return AppStrings.verySlowCharging;
    if (power < 10) return AppStrings.slowCharging;
    if (power < 15) return AppStrings.normalCharging;
    if (power < 20) return AppStrings.fastCharging;
    return AppStrings.ultraFastCharging;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: isCharging 
                    ? AppColors.charging.withOpacity(0.1)
                    : AppColors.notCharging.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCharging ? Icons.power : Icons.power_off,
                  color: isCharging ? AppColors.charging : AppColors.notCharging,
                  size: AppDimensions.iconSizeMedium,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCharging ? AppStrings.charging : AppStrings.notPlugged,
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeExtraLarge,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    isCharging ? AppStrings.analysisInProgress : AppStrings.plugCharger,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isCharging) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingSmall, 
                horizontal: AppDimensions.paddingMedium
              ),
              decoration: BoxDecoration(
                color: _getPowerColor(power).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
              ),
              child: Text(
                _getChargingQuality(power),
                style: TextStyle(
                  color: _getPowerColor(power),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}