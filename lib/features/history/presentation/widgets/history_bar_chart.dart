import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../diary/data/diary_providers.dart';
import '../../data/history_providers.dart';
import '../../domain/nutrition_history_aggregator.dart';

class HistoryBarChart extends ConsumerWidget {
  const HistoryBarChart({
    required this.report,
    required this.viewMode,
    super.key,
  });

  final HistoryReport report;
  final HistoryViewMode viewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartMode = ref.watch(historyChartDisplayModeProvider);
    final isMacroMode = chartMode == ChartDisplayMode.macro;
    final isMonth = viewMode == HistoryViewMode.month;

    // Calculate maximum Y value
    double maxLoggedKcal = 0.0;
    for (final day in report.days) {
      if (day.hasLog) {
        if (isMacroMode) {
          final macroKcal = (day.summary.total.protein * 4) +
              (day.summary.total.carb * 4) +
              (day.summary.total.fat * 9);
          if (macroKcal > maxLoggedKcal) maxLoggedKcal = macroKcal;
        } else {
          if (day.summary.total.kcal > maxLoggedKcal) {
            maxLoggedKcal = day.summary.total.kcal;
          }
        }
      }
    }

    final targetKcal = report.targetKcal.toDouble();
    final effectiveMax = max(targetKcal, maxLoggedKcal);
    final maxY = (effectiveMax > 0 ? effectiveMax * 1.2 : 2500.0).ceilToDouble();

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < report.days.length; i++) {
      final dayItem = report.days[i];

      if (!dayItem.hasLog) {
        // Unlogged day: empty bar
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: 0,
                color: Colors.transparent,
                width: isMonth ? 6.0 : 20.0,
              ),
            ],
          ),
        );
      } else if (!isMacroMode) {
        // Calorie mode: neutral single color bar
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dayItem.summary.total.kcal,
                color: AppColors.primary,
                width: isMonth ? 6.0 : 20.0,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        );
      } else {
        // Macro mode: stacked bar (Protein * 4, Carb * 4, Fat * 9)
        final pKcal = dayItem.summary.total.protein * 4;
        final cKcal = dayItem.summary.total.carb * 4;
        final fKcal = dayItem.summary.total.fat * 9;
        final totalMacroKcal = pKcal + cKcal + fKcal;

        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: totalMacroKcal > 0 ? totalMacroKcal : 0.1,
                width: isMonth ? 6.0 : 20.0,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                rodStackItems: [
                  BarChartRodStackItem(0, pKcal, AppColors.protein),
                  BarChartRodStackItem(pKcal, pKcal + cKcal, AppColors.carb),
                  BarChartRodStackItem(pKcal + cKcal, totalMacroKcal, AppColors.fat),
                ],
              ),
            ],
          ),
        );
      }
    }

    final semanticsLabel = '${l10n.chartSemantics}: '
        '${report.daysWithLogCount}/${report.totalDays} ngày có ghi chép. '
        'Trung bình ${report.averageKcal.round()} kcal/ngày. '
        'Mục tiêu ${report.targetKcal} kcal.';

    return Semantics(
      label: semanticsLabel,
      container: true,
      child: Card(
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
              // Chart Header: Title & Calo/Macro Segmented Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMacroMode ? l10n.macros : l10n.calories,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SegmentedButton<ChartDisplayMode>(
                    segments: [
                      ButtonSegment<ChartDisplayMode>(
                        value: ChartDisplayMode.calorie,
                        label: Text(l10n.calories),
                      ),
                      ButtonSegment<ChartDisplayMode>(
                        value: ChartDisplayMode.macro,
                        label: Text(l10n.macros),
                      ),
                    ],
                    selected: {chartMode},
                    onSelectionChanged: (newSelection) {
                      ref.read(historyChartDisplayModeProvider.notifier).state = newSelection.first;
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Macro Legend when in Macro mode
              if (isMacroMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Protein (x4)', AppColors.protein),
                    const SizedBox(width: 16),
                    _buildLegendItem('Carb (x4)', AppColors.carb),
                    const SizedBox(width: 16),
                    _buildLegendItem('Fat (x9)', AppColors.fat),
                  ],
                ),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 12),

              // Bar Chart
              SizedBox(
                height: 240,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    minY: 0,
                    barGroups: barGroups,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: (maxY / 4).clamp(200.0, 1000.0),
                      getDrawingHorizontalLine: (value) => FlLine(
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
                          reservedSize: 42,
                          interval: (maxY / 4).clamp(200.0, 1000.0),
                          getTitlesWidget: (value, _) {
                            if (value == 0 || value > maxY) return const SizedBox.shrink();
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            if (index < 0 || index >= report.days.length) {
                              return const SizedBox.shrink();
                            }
                            final item = report.days[index];

                            if (isMonth) {
                              // Month: space out day labels (day 1, 5, 10, 15, 20, 25, last day)
                              final dayNum = item.date.day;
                              final isLast = index == report.days.length - 1;
                              final shouldShow = dayNum == 1 || dayNum % 5 == 0 || isLast;
                              if (!shouldShow) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  dayNum.toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              );
                            } else {
                              // Week: T2, T3, T4, T5, T6, T7, CN
                              final weekdayLabel = _getWeekdayShortLabel(item.date, l10n.localeName);
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  weekdayLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: item.hasLog ? FontWeight.w600 : FontWeight.normal,
                                    color: item.hasLog
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : (isDark ? Colors.white38 : Colors.black38),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: targetKcal,
                          color: isDark ? Colors.white54 : Colors.black45,
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 4, bottom: 2),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            labelResolver: (line) => '${targetKcal.toInt()} kcal',
                          ),
                        ),
                      ],
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) =>
                            isDark ? AppColors.surfaceVariantDark : const Color(0xFF1E293B),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (groupIndex < 0 || groupIndex >= report.days.length) return null;
                          final item = report.days[groupIndex];
                          final dateStr = DateFormat('dd/MM', l10n.localeName).format(item.date);

                          if (!item.hasLog) {
                            return BarTooltipItem(
                              '$dateStr\n${l10n.unlogged}',
                              const TextStyle(color: Colors.white70, fontSize: 12),
                            );
                          }

                          if (isMacroMode) {
                            final p = item.summary.total.protein.round();
                            final c = item.summary.total.carb.round();
                            final f = item.summary.total.fat.round();
                            return BarTooltipItem(
                              '$dateStr\n${item.summary.totalKcal} kcal\nP: ${p}g | C: ${c}g | F: ${f}g',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return BarTooltipItem(
                              '$dateStr\n${item.summary.totalKcal} kcal',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent && response != null && response.spot != null) {
                          final index = response.spot!.touchedBarGroupIndex;
                          if (index >= 0 && index < report.days.length) {
                            final tappedItem = report.days[index];
                            ref.read(selectedDateProvider.notifier).state = tappedItem.date;
                            context.go('/');
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),

              // Subtle note about unlogged days when in week view
              if (!isMonth && report.days.any((d) => !d.hasLog)) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: isDark ? Colors.white38 : Colors.black38),
                    const SizedBox(width: 4),
                    Text(
                      'Cột trống = ngày chưa ghi chép',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _getWeekdayShortLabel(DateTime date, String locale) {
    if (locale == 'vi') {
      switch (date.weekday) {
        case DateTime.monday:
          return 'T2';
        case DateTime.tuesday:
          return 'T3';
        case DateTime.wednesday:
          return 'T4';
        case DateTime.thursday:
          return 'T5';
        case DateTime.friday:
          return 'T6';
        case DateTime.saturday:
          return 'T7';
        case DateTime.sunday:
          return 'CN';
      }
    }
    return DateFormat('E', locale).format(date);
  }
}
