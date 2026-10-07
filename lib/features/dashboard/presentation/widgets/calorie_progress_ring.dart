import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CalorieProgressRing extends StatelessWidget {
  const CalorieProgressRing({
    required this.consumedKcal,
    required this.targetKcal,
    required this.remainingKcal,
    required this.isExceeded,
    super.key,
  });

  final int consumedKcal;
  final int targetKcal;
  final int remainingKcal;
  final bool isExceeded;

  @override
  Widget build(BuildContext context) {
    final ratio = targetKcal > 0 ? (consumedKcal / targetKcal) : 0.0;
    final progressValue = ratio.clamp(0.0, 1.0);
    final statusColor = isExceeded ? AppColors.calorieOver : AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final semanticLabel = isExceeded
        ? 'Đã nạp $consumedKcal trên mục tiêu $targetKcal kcal. Đã vượt ${-remainingKcal} kcal.'
        : 'Đã nạp $consumedKcal trên mục tiêu $targetKcal kcal. Còn lại $remainingKcal kcal.';

    return Semantics(
      label: semanticLabel,
      child: Center(
        child: SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.borderLight,
                ),
              ),

              // Animated progress ring
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progressValue),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      color: statusColor,
                    ),
                  );
                },
              ),

              // Central text display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ĐÃ NẠP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    consumedKcal.toString(),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'kcal / $targetKcal kcal',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Remaining or Exceeded pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExceeded
                          ? 'Đã vượt ${-remainingKcal} kcal'
                          : 'Còn lại $remainingKcal kcal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
