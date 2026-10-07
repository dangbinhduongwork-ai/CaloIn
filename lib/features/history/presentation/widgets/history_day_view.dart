import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../diary/data/diary_providers.dart';
import '../../../diary/domain/meal_type.dart';
import '../../domain/nutrition_history_aggregator.dart';

class HistoryDayView extends ConsumerWidget {
  const HistoryDayView({
    required this.dayItem,
    required this.targetKcal,
    super.key,
  });

  final DayHistoryItem dayItem;
  final int targetKcal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!dayItem.hasLog) {
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
          padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.unlogged,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Ngày này chưa có bản ghi dinh dưỡng nào.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Ghi chép cho ngày này'),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state = dayItem.date;
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      );
    }

    final summary = dayItem.summary;
    final breakfastKcal = summary.meals[MealType.breakfast]?.kcal ?? 0.0;
    final lunchKcal = summary.meals[MealType.lunch]?.kcal ?? 0.0;
    final dinnerKcal = summary.meals[MealType.dinner]?.kcal ?? 0.0;
    final snackKcal = summary.meals[MealType.snack]?.kcal ?? 0.0;

    final List<double> mealValues = [breakfastKcal, lunchKcal, dinnerKcal, snackKcal];
    final maxMealKcal = mealValues.reduce(max);
    final maxY = max(1000.0, maxMealKcal * 1.25);

    // Macro percentages
    final totalMacroKcal = (summary.total.protein * 4) + (summary.total.carb * 4) + (summary.total.fat * 9);
    final proteinPct = totalMacroKcal > 0 ? ((summary.total.protein * 4 / totalMacroKcal) * 100).round() : 0;
    final carbPct = totalMacroKcal > 0 ? ((summary.total.carb * 4 / totalMacroKcal) * 100).round() : 0;
    final fatPct = totalMacroKcal > 0 ? (100 - proteinPct - carbPct) : 0;

    return Column(
      children: [
        // Meal Breakdown Bar Chart Card
        Card(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.mealsBreakdown,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${summary.totalKcal} kcal',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      minY: 0,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (val) => FlLine(
                          color: isDark ? Colors.white10 : Colors.black12,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: (maxY / 3).clamp(100.0, 500.0),
                            getTitlesWidget: (val, _) => Text(
                              val.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (val, _) {
                              String label;
                              switch (val.toInt()) {
                                case 0:
                                  label = l10n.breakfast;
                                  break;
                                case 1:
                                  label = l10n.lunch;
                                  break;
                                case 2:
                                  label = l10n.dinner;
                                  break;
                                case 3:
                                  label = l10n.snack;
                                  break;
                                default:
                                  label = '';
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: breakfastKcal,
                              color: AppColors.primary,
                              width: 24,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: lunchKcal,
                              color: AppColors.primary,
                              width: 24,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: dinnerKcal,
                              color: AppColors.primary,
                              width: 24,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(
                              toY: snackKcal,
                              color: AppColors.primary,
                              width: 24,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Day Macro Proportion Table Card
        Card(
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
                Text(
                  l10n.macroRatioTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildMacroTableRow(
                  label: l10n.protein,
                  grams: summary.total.protein,
                  kcal: (summary.total.protein * 4).round(),
                  pct: proteinPct,
                  color: AppColors.protein,
                  isDark: isDark,
                ),
                const Divider(height: 16),
                _buildMacroTableRow(
                  label: l10n.carb,
                  grams: summary.total.carb,
                  kcal: (summary.total.carb * 4).round(),
                  pct: carbPct,
                  color: AppColors.carb,
                  isDark: isDark,
                ),
                const Divider(height: 16),
                _buildMacroTableRow(
                  label: l10n.fat,
                  grams: summary.total.fat,
                  kcal: (summary.total.fat * 9).round(),
                  pct: fatPct,
                  color: AppColors.fat,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                // Tap to view/edit in Today tab
                InkWell(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state = dayItem.date;
                    context.go('/');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Xem và chỉnh sửa nhật ký ngày này',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroTableRow({
    required String label,
    required double grams,
    required int kcal,
    required int pct,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '${grams.round()}g',
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '$kcal kcal',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '$pct%',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
