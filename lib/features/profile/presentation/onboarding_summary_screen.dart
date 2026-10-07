import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../data/onboarding_draft_provider.dart';
import '../data/profile_providers.dart';
import '../domain/calorie_goal_calculator.dart';
import '../domain/macro_split.dart';
import '../domain/profile_enums.dart';
import 'widgets/macro_ratio_selector.dart';

class OnboardingSummaryScreen extends ConsumerStatefulWidget {
  const OnboardingSummaryScreen({this.isEditing = false, super.key});

  final bool isEditing;

  @override
  ConsumerState<OnboardingSummaryScreen> createState() => _OnboardingSummaryScreenState();
}

class _OnboardingSummaryScreenState extends ConsumerState<OnboardingSummaryScreen> {
  late int _targetKcal;
  late bool _isGoalManual;
  late MacroSplit _macroSplit;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingDraftProvider);
    final calc = draft.calculateResult();
    _targetKcal = draft.customDailyGoalKcal ?? calc.targetKcal;
    _isGoalManual = draft.isGoalManual;
    _macroSplit = draft.macroSplit;
  }

  Future<void> _editManualTarget(int safeFloor) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: _targetKcal.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.calorieTarget),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              suffixText: 'kcal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val > 0) {
                  Navigator.of(ctx).pop(val);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      if (result < safeFloor) {
        // Warning dialog for below floor
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(l10n.warning),
                ],
              ),
              content: Text(l10n.manualFloorWarning(result, safeFloor)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.calorieOver),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );

        if (proceed != true) return;
      }

      setState(() {
        _targetKcal = result;
        _isGoalManual = true;
      });
    }
  }

  void _resetToSuggested(int suggestedKcal) {
    setState(() {
      _targetKcal = suggestedKcal;
      _isGoalManual = false;
    });
  }

  Future<void> _completeOnboarding() async {
    final draft = ref.read(onboardingDraftProvider);
    final profile = draft.toUserProfile().copyWith(
          dailyGoalKcal: _targetKcal,
          isGoalManual: _isGoalManual,
          macroSplit: _macroSplit,
        );

    await ref.read(profileProvider.notifier).saveProfile(profile);

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefHasCompletedOnboarding, true);

    if (mounted) {
      if (widget.isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật hồ sơ thành công')),
        );
        context.go('/settings');
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(onboardingDraftProvider);
    final calc = draft.calculateResult();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeFloor = CalorieGoalCalculator.getSafeFloor(draft.gender);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.formulaSummaryTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Target Card
              Card(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainer.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.targetCalories(_targetKcal),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _editManualTarget(safeFloor),
                          ),
                        ],
                      ),
                      if (_isGoalManual) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Mục tiêu tự chỉnh',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => _resetToSuggested(calc.targetKcal),
                              child: const Text('Dùng mức đề xuất'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Safe Floor or Not Advisable Notices
              if (calc.floorApplied) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade400),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.floorWarning(safeFloor),
                          style: TextStyle(
                            color: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (calc.lossNotAdvisable) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade600),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.amber.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Với thông số thể trạng hiện tại, mức calo an toàn tối thiểu (${safeFloor} kcal) cao hơn năng lượng tiêu hao hàng ngày (TDEE: ${calc.tdee.round()} kcal). App đã đặt mục tiêu ở mức giữ cân để bảo vệ sức khỏe. Hãy tham khảo ý kiến chuyên gia dinh dưỡng.',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Energy Metrics Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chi tiết tính toán năng lượng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow('BMR (Trao đổi chất cơ bản)', AppFormatters.formatKcalWithUnit(calc.bmr)),
                      const Divider(height: 16),
                      _buildMetricRow('TDEE (Tổng tiêu hao/ngày)', AppFormatters.formatKcalWithUnit(calc.tdee)),
                      const Divider(height: 16),
                      _buildMetricRow(
                        'Mục tiêu thể trạng',
                        switch (draft.goal) {
                          Goal.lose => 'Giảm cân (-500 kcal)',
                          Goal.maintain => 'Giữ cân (0 kcal)',
                          Goal.gain => 'Tăng cân (+300 kcal)',
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Công thức Mifflin-St Jeor: ${draft.gender.isMale ? '10×kg + 6.25×cm − 5×tuổi + 5' : '10×kg + 6.25×cm − 5×tuổi − 161'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Macro Distribution Section
              const Text(
                'Phân bổ dinh dưỡng đa lượng (Macro)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              MacroRatioSelector(
                targetKcal: _targetKcal,
                initialSplit: _macroSplit,
                onSplitChanged: (newSplit) {
                  setState(() => _macroSplit = newSplit);
                },
              ),
              const SizedBox(height: 24),

              // Mandatory Disclaimer Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.disclaimer,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Get Started Button
              FilledButton(
                onPressed: _macroSplit.isValid ? _completeOnboarding : null,
                child: Text(widget.isEditing ? 'Lưu thay đổi' : l10n.getStarted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
