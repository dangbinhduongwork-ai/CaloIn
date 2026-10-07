import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../diary/data/diary_providers.dart';
import '../../domain/nutrition_history_aggregator.dart';

class HistoryStatsCard extends ConsumerWidget {
  const HistoryStatsCard({
    required this.report,
    super.key,
  });

  final HistoryReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (report.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 40,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noHistoryData,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.historySummaryTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2-column key metrics: Logged days & Average kcal
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: l10n.loggedDaysCount,
                    value: '${report.daysWithLogCount} / ${report.totalDays} ngày',
                    subtext: '${(report.daysWithLogCount / report.totalDays * 100).round()}% khoảng thời gian',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: l10n.dailyAverage,
                    value: '${report.averageKcal.round()} kcal',
                    subtext: 'trên ${report.daysWithLogCount} ngày có ghi',
                    valueColor: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Macro Averages Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark.withAlpha(128) : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.macroAverage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroAvgCol(
                        label: l10n.proteinShort,
                        grams: report.averageProtein.round(),
                        color: AppColors.protein,
                      ),
                      _buildMacroAvgCol(
                        label: l10n.carbShort,
                        grams: report.averageCarb.round(),
                        color: AppColors.carb,
                      ),
                      _buildMacroAvgCol(
                        label: l10n.fatShort,
                        grams: report.averageFat.round(),
                        color: AppColors.fat,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Highest & Lowest Days
            if (report.highestDay != null && report.lowestDay != null) ...[
              _buildExtremumRow(
                context: context,
                ref: ref,
                icon: Icons.north_rounded,
                iconColor: const Color(0xFFE11D48),
                title: l10n.highestDayLabel,
                dayItem: report.highestDay!,
                locale: l10n.localeName,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildExtremumRow(
                context: context,
                ref: ref,
                icon: Icons.south_rounded,
                iconColor: const Color(0xFF0284C7),
                title: l10n.lowestDayLabel,
                dayItem: report.lowestDay!,
                locale: l10n.localeName,
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtext,
    Color? valueColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark.withAlpha(128) : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroAvgCol({
    required String label,
    required int grams,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(
          '${grams}g',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildExtremumRow({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required Color iconColor,
    required String title,
    required DayHistoryItem dayItem,
    required String locale,
    required bool isDark,
  }) {
    final dateStr = DateFormat('dd/MM', locale).format(dayItem.date);

    return InkWell(
      onTap: () {
        ref.read(selectedDateProvider.notifier).state = dayItem.date;
        context.go('/');
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 8),
            Text(
              '$title ($dateStr):',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '${dayItem.summary.totalKcal} kcal',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: isDark ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }
}
