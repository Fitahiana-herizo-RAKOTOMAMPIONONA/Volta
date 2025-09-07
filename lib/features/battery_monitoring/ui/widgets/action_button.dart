import 'package:flutter/material.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dimension.dart';
import '../../../../core/constant/app_string.dart';


class ActionButtons extends StatelessWidget {
  final bool isCharging;
  final bool isMonitoring;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  const ActionButtons({
    super.key,
    required this.isCharging,
    required this.isMonitoring,
    this.onStart,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isCharging && !isMonitoring ? onStart : null,
            icon: const Icon(Icons.play_arrow, size: AppDimensions.iconSizeSmall),
            label: const Text(AppStrings.start),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.charging,
              side: const BorderSide(color: AppColors.charging),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isMonitoring ? onStop : null,
            icon: const Icon(Icons.stop, size: AppDimensions.iconSizeSmall),
            label: const Text(AppStrings.stop),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.notCharging,
              side: const BorderSide(color: AppColors.notCharging),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }
}