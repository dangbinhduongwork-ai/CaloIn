import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/data/profile_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileProvider);
    final target = ref.watch(nutritionTargetProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(l10n.getStarted));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Daily Target Card
                Card(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainer.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          l10n.targetCalories(profile.dailyGoalKcal),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile.isGoalManual ? 'Mục tiêu tự chỉnh' : 'Mục tiêu tự động (Mifflin-St Jeor)',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Macro targets
                        if (target != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMacroTargetStat(
                                'Đạm',
                                AppFormatters.formatMacroWithUnit(target.proteinGrams),
                                AppColors.protein,
                              ),
                              _buildMacroTargetStat(
                                'Carb',
                                AppFormatters.formatMacroWithUnit(target.carbGrams),
                                AppColors.carb,
                              ),
                              _buildMacroTargetStat(
                                'Béo',
                                AppFormatters.formatMacroWithUnit(target.fatGrams),
                                AppColors.fat,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Profile Summary card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin thể trạng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildRow('Giới tính', profile.gender.isMale ? l10n.male : l10n.female),
                        const Divider(height: 16),
                        _buildRow('Tuổi', '${profile.age} tuổi'),
                        const Divider(height: 16),
                        _buildRow('Chiều cao', '${profile.heightCm.round()} cm'),
                        const Divider(height: 16),
                        _buildRow('Cân nặng', '${profile.weightKg.toStringAsFixed(1)} kg'),
                        const Divider(height: 16),
                        _buildRow(
                          'Mục tiêu',
                          switch (profile.goal) {
                            var g when g.name == 'lose' => l10n.loseWeight,
                            var g when g.name == 'gain' => l10n.gainWeight,
                            _ => l10n.maintainWeight,
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMacroTargetStat(String title, String grams, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          grams,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
