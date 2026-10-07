import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/history_providers.dart';

class HistoryPeriodSelector extends ConsumerWidget {
  const HistoryPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mode = ref.watch(historyViewModeProvider);
    final range = ref.watch(historyDateRangeProvider);
    final canGoNext = ref.watch(canHistoryGoNextProvider);
    final refDate = ref.watch(historyReferenceDateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Segmented Button: Day / Week / Month
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<HistoryViewMode>(
              segments: [
                ButtonSegment<HistoryViewMode>(
                  value: HistoryViewMode.day,
                  label: Text(l10n.dayView),
                  icon: const Icon(Icons.today, size: 18),
                ),
                ButtonSegment<HistoryViewMode>(
                  value: HistoryViewMode.week,
                  label: Text(l10n.weekView),
                  icon: const Icon(Icons.view_week, size: 18),
                ),
                ButtonSegment<HistoryViewMode>(
                  value: HistoryViewMode.month,
                  label: Text(l10n.monthView),
                  icon: const Icon(Icons.calendar_month, size: 18),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (newSelection) {
                ref.read(historyViewModeProvider.notifier).state = newSelection.first;
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                side: WidgetStatePropertyAll(
                  BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date Range Navigation: [<] [Label] [>]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const Key('history_prev_button'),
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Trước',
                onPressed: () {
                  final current = ref.read(historyReferenceDateProvider);
                  DateTime newDate;
                  switch (mode) {
                    case HistoryViewMode.day:
                      newDate = DateTime(current.year, current.month, current.day - 1);
                      break;
                    case HistoryViewMode.week:
                      newDate = DateTime(current.year, current.month, current.day - 7);
                      break;
                    case HistoryViewMode.month:
                      newDate = DateTime(current.year, current.month - 1, 1);
                      break;
                  }
                  ref.read(historyReferenceDateProvider.notifier).state = newDate;
                },
              ),
              Expanded(
                child: Text(
                  _formatPeriodLabel(mode, range, refDate, l10n.locale.languageCode),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                key: const Key('history_next_button'),
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Sau',
                onPressed: canGoNext
                    ? () {
                        final current = ref.read(historyReferenceDateProvider);
                        DateTime newDate;
                        switch (mode) {
                          case HistoryViewMode.day:
                            newDate = DateTime(current.year, current.month, current.day + 1);
                            break;
                          case HistoryViewMode.week:
                            newDate = DateTime(current.year, current.month, current.day + 7);
                            break;
                          case HistoryViewMode.month:
                            newDate = DateTime(current.year, current.month + 1, 1);
                            break;
                        }
                        ref.read(historyReferenceDateProvider.notifier).state = newDate;
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPeriodLabel(HistoryViewMode mode, DateRange range, DateTime refDate, String locale) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (mode) {
      case HistoryViewMode.day:
        final date = range.start;
        final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
        final dateStr = DateFormat('dd/MM/yyyy', locale).format(date);
        if (isToday) {
          return locale == 'vi' ? 'Hôm nay, $dateStr' : 'Today, $dateStr';
        }
        final weekdayStr = DateFormat('EEEE', locale).format(date);
        return '$weekdayStr, $dateStr';

      case HistoryViewMode.week:
        final startStr = DateFormat('dd/MM', locale).format(range.start);
        final endStr = DateFormat('dd/MM/yyyy', locale).format(range.end);
        return '$startStr - $endStr';

      case HistoryViewMode.month:
        if (locale == 'vi') {
          return 'Tháng ${range.start.month}, ${range.start.year}';
        }
        return DateFormat('MMMM yyyy', locale).format(range.start);
    }
  }
}
