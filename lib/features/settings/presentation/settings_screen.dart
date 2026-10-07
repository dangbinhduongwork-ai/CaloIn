import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../l10n/app_localizations.dart';
import '../../foods/data/food_repository_provider.dart';
import '../../profile/data/onboarding_draft_provider.dart';
import '../../profile/data/profile_providers.dart';
import '../../profile/domain/calorie_goal_calculator.dart';
import '../../profile/domain/macro_split.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/presentation/widgets/macro_ratio_selector.dart';
import '../data/settings_provider.dart';
import '../domain/settings_enums.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSettings, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Chưa có hồ sơ'));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // 1. Profile & Goal Section
              _buildSectionHeader(l10n.profileSection, Icons.person_rounded),
              _buildProfileCard(context, ref, profile, settings, isDark, l10n),
              const SizedBox(height: 20),

              // 2. Units Section
              _buildSectionHeader(l10n.units, Icons.straighten_rounded),
              _buildUnitsCard(context, ref, settings, isDark, l10n),
              const SizedBox(height: 20),

              // 3. Appearance & Language
              _buildSectionHeader(l10n.appearanceLanguageSection, Icons.palette_rounded),
              _buildAppearanceCard(context, ref, isDark, l10n),
              const SizedBox(height: 20),

              // 4. Data Management
              _buildSectionHeader(l10n.dataSection, Icons.storage_rounded),
              _buildDataCard(context, ref, isDark, l10n),
              const SizedBox(height: 20),

              // 5. About & Medical Disclaimer
              _buildSectionHeader(l10n.aboutApp, Icons.info_outline_rounded),
              _buildAboutCard(context, isDark, l10n),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    UserSettings settings,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Format height and weight according to user settings
    final weightStr = settings.weightUnit.isKg
        ? '${profile.weightKg.toStringAsFixed(1)} kg'
        : '${UnitConverter.kgToLb(profile.weightKg).toStringAsFixed(1)} lb';

    final heightStr = settings.heightUnit.isCm
        ? '${profile.heightCm.round()} cm'
        : UnitConverter.cmToFtIn(profile.heightCm);

    final genderStr = profile.gender.isMale ? l10n.male : l10n.female;
    final targetStr = '${profile.dailyGoalKcal} kcal';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    profile.gender.isMale ? Icons.face_rounded : Icons.face_3_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$genderStr • ${profile.age} tuổi',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$heightStr • $weightStr',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    targetStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Macro breakdown preview
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark.withAlpha(128) : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroRatioBadge('Protein: ${profile.macroSplit.proteinPct}%', AppColors.protein),
                  _buildMacroRatioBadge('Carb: ${profile.macroSplit.carbPct}%', AppColors.carb),
                  _buildMacroRatioBadge('Fat: ${profile.macroSplit.fatPct}%', AppColors.fat),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: Text(l10n.editGoals),
                    onPressed: () => _openGoalsBottomSheet(context, ref, profile),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: Text(l10n.editFullProfile),
                    onPressed: () {
                      ref.read(onboardingDraftProvider.notifier).state =
                          OnboardingDraft.fromUserProfile(profile);
                      context.push('/onboarding?isEditing=true');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRatioBadge(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildUnitsCard(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.weightUnitLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                    ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                  ],
                  selected: {settings.weightUnit},
                  onSelectionChanged: (newVal) {
                    ref.read(settingsProvider.notifier).setWeightUnit(newVal.first);
                  },
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.heightUnitLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SegmentedButton<HeightUnit>(
                  segments: const [
                    ButtonSegment(value: HeightUnit.cm, label: Text('cm')),
                    ButtonSegment(value: HeightUnit.ftIn, label: Text('ft/in')),
                  ],
                  selected: {settings.heightUnit},
                  onSelectionChanged: (newVal) {
                    ref.read(settingsProvider.notifier).setHeightUnit(newVal.first);
                  },
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.themeMode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
                    ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
                    ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
                  ],
                  selected: {currentTheme},
                  onSelectionChanged: (newVal) {
                    ref.read(themeModeProvider.notifier).setThemeMode(newVal.first);
                  },
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.language, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'system', label: Text('Hệ thống')),
                    ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {currentLocale == null ? 'system' : currentLocale.languageCode},
                  onSelectionChanged: (newVal) {
                    final code = newVal.first;
                    if (code == 'system') {
                      ref.read(localeProvider.notifier).setLocale(null);
                    } else {
                      ref.read(localeProvider.notifier).setLocale(Locale(code));
                    }
                  },
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary),
            title: Text(l10n.manageFoods, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(l10n.manageFoodsSubtitle, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/foods'),
          ),
          Divider(height: 1, indent: 16, endIndent: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            title: Text(l10n.deleteAllData, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
            subtitle: Text(l10n.deleteAllDataConfirm, style: const TextStyle(fontSize: 12)),
            onTap: () => _showDeleteAllDataDialog(context, ref, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.appVersionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.bmrExplanation,
              style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tdeeExplanation,
              style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.safeFloorInfo,
              style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark.withAlpha(128) : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nguồn dữ liệu & Đối chiếu Atwater:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dataSourceInfo,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.openFoodFactsAttribution,
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.health_and_safety_outlined, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.medicalDisclaimerFull,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.amber.shade200 : Colors.brown.shade800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoalsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final l10n = AppLocalizations.of(context);
    int currentKcal = profile.dailyGoalKcal;
    MacroSplit currentSplit = profile.macroSplit;
    bool isManual = profile.isGoalManual;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final calculatedGoal = CalorieGoalCalculator.calculate(
              gender: profile.gender,
              age: profile.age,
              heightCm: profile.heightCm,
              weightKg: profile.weightKg,
              activityLevel: profile.activityLevel,
              goal: profile.goal,
            );

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.editGoals,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Daily Goal Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.calorieTarget, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Text(
                              isManual ? 'Tự thiết lập' : 'Tự động tính từ TDEE',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '$currentKcal kcal',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () async {
                                final controller = TextEditingController(text: currentKcal.toString());
                                final newVal = await showDialog<int>(
                                  context: ctx,
                                  builder: (dCtx) => AlertDialog(
                                    title: Text(l10n.calorieTarget),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      decoration: const InputDecoration(suffixText: 'kcal'),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(dCtx).pop(), child: Text(l10n.cancel)),
                                      FilledButton(
                                        onPressed: () {
                                          final parsed = int.tryParse(controller.text);
                                          if (parsed != null && parsed > 500) {
                                            Navigator.of(dCtx).pop(parsed);
                                          }
                                        },
                                        child: Text(l10n.save),
                                      ),
                                    ],
                                  ),
                                );
                                if (newVal != null) {
                                  setModalState(() {
                                    currentKcal = newVal;
                                    isManual = true;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isManual) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Dùng mức đề xuất theo TDEE'),
                          onPressed: () {
                            setModalState(() {
                              currentKcal = calculatedGoal.targetKcal;
                              isManual = false;
                            });
                          },
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    Text(l10n.macroRatioTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // Reusing MacroRatioSelector directly
                    MacroRatioSelector(
                      targetKcal: currentKcal,
                      initialSplit: currentSplit,
                      onSplitChanged: (newSplit) {
                        setModalState(() => currentSplit = newSplit);
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: currentSplit.isValid
                          ? () async {
                              await ref.read(profileProvider.notifier).updateGoals(
                                    dailyGoalKcal: currentKcal,
                                    isGoalManual: isManual,
                                    macroSplit: currentSplit,
                                  );
                              if (context.mounted) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.goalsUpdatedSuccess)),
                                );
                              }
                            }
                          : null,
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteAllDataDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAllData),
        content: Text(l10n.deleteAllDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.clearAndReset),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      final prefs = ref.read(sharedPreferencesProvider);

      // 1. Delete all food logs
      await db.delete(db.foodLogs).go();

      // 2. Delete all custom foods
      await (db.delete(db.foods)..where((t) => t.isCustom.equals(true))).go();

      // 3. Reset favorite status on seed foods
      await (db.update(db.foods)).write(FoodsCompanion(isFavorite: drift.Value(false)));

      // 4. Delete user profile
      await ref.read(profileProvider.notifier).clearProfile();

      // 5. Reset onboarding completed flag
      await prefs.setBool(AppConstants.prefHasCompletedOnboarding, false);

      // 6. Reload seed foods
      final jsonStr = await rootBundle.loadString('assets/data/foods_seed.json');
      final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;
      final List<dynamic> foodsList = data['foods'] as List<dynamic>;
      final rawFoods = foodsList.cast<Map<String, dynamic>>();
      await ref.read(foodRepositoryProvider).seedFoods(rawFoods, version: AppConstants.currentSeedVersion);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dataClearedSuccess)),
        );
        // Router will automatically redirect to /onboarding because profile is null
        context.go('/onboarding');
      }
    }
  }
}
