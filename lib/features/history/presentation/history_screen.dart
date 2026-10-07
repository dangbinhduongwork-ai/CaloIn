import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/debug_sample_data.dart';
import '../data/history_providers.dart';
import 'widgets/history_bar_chart.dart';
import 'widgets/history_day_list.dart';
import 'widgets/history_day_view.dart';
import 'widgets/history_period_selector.dart';
import 'widgets/history_stats_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _handleGenerateDebugData(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final l10n = AppLocalizations.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang tạo 60 ngày dữ liệu mẫu...'),
        duration: Duration(seconds: 1),
      ),
    );

    final count = await generate60DaysSampleData(db);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.sampleDataGenerated} ($count bản ghi)'),
          backgroundColor: Colors.teal.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(historyViewModeProvider);
    final reportAsync = ref.watch(historyReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHistory, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (kDebugMode)
            IconButton(
              key: const Key('history_debug_generate_button'),
              icon: const Icon(Icons.auto_awesome),
              tooltip: l10n.generateSampleData,
              onPressed: () => _handleGenerateDebugData(context, ref),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Period selector (Day / Week / Month & Prev / Next)
            const HistoryPeriodSelector(),
            const Divider(height: 1),

            // Content
            Expanded(
              child: reportAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.amber),
                        const SizedBox(height: 12),
                        Text(
                          'Không thể tải dữ liệu lịch sử',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                data: (report) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      children: [
                        if (mode == HistoryViewMode.day) ...[
                          if (report.days.isNotEmpty)
                            HistoryDayView(
                              dayItem: report.days.first,
                              targetKcal: report.targetKcal,
                            ),
                        ] else ...[
                          // Week / Month modes: Chart + Statistics + Day List
                          HistoryBarChart(report: report, viewMode: mode),
                          HistoryStatsCard(report: report),
                          HistoryDayList(report: report),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
