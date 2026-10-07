import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class MacroBarsCard extends StatelessWidget {
  const MacroBarsCard({
    required this.consumedProtein,
    required this.targetProtein,
    required this.consumedCarb,
    required this.targetCarb,
    required this.consumedFat,
    required this.targetFat,
    super.key,
  });

  final double consumedProtein;
  final double targetProtein;
  final double consumedCarb;
  final double targetCarb;
  final double consumedFat;
  final double targetFat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            _buildMacroRow(
              context,
              name: 'Đạm (Protein)',
              consumed: consumedProtein,
              target: targetProtein,
              color: AppColors.protein,
            ),
            const SizedBox(height: 12),
            _buildMacroRow(
              context,
              name: 'Carb (Tinh bột)',
              consumed: consumedCarb,
              target: targetCarb,
              color: AppColors.carb,
            ),
            const SizedBox(height: 12),
            _buildMacroRow(
              context,
              name: 'Béo (Fat)',
              consumed: consumedFat,
              target: targetFat,
              color: AppColors.fat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(
    BuildContext context, {
    required String name,
    required double consumed,
    required double target,
    required Color color,
  }) {
    final ratio = target > 0 ? (consumed / target) : 0.0;
    final progress = ratio.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              '${AppFormatters.formatMacro(consumed)} / ${AppFormatters.formatMacroWithUnit(target)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
