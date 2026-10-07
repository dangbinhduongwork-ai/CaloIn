import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../diary/data/diary_providers.dart';
import '../../domain/nutrition_history_aggregator.dart';

class HistoryDayList extends ConsumerWidget {
  const HistoryDayList({
    required this.report,
    super.key,
  });

  final HistoryReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Display days in reverse chronological order (newest first)
    final reversedDays = report.days.reversed.toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: [
                const Icon(Icons.list_alt_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Chi tiết từng ngày',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reversedDays.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            itemBuilder: (context, index) {
              final dayItem = reversedDays[index];
              final dateStr = DateFormat('EEEE, dd/MM', l10n.localeName).format(dayItem.date);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = dayItem.date;
                  context.go('/');
                },
                title: Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: dayItem.hasLog ? FontWeight.w600 : FontWeight.normal,
                    color: dayItem.hasLog
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black38),
                  ),
                ),
                subtitle: dayItem.hasLog
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            _buildMacroChip('P: ${dayItem.summary.total.protein.round()}g', AppColors.protein),
                            const SizedBox(width: 6),
                            _buildMacroChip('C: ${dayItem.summary.total.carb.round()}g', AppColors.carb),
                            const SizedBox(width: 6),
                            _buildMacroChip('F: ${dayItem.summary.total.fat.round()}g', AppColors.fat),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          l10n.unlogged,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dayItem.hasLog)
                      Text(
                        '${dayItem.summary.totalKcal} kcal',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        '--',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
