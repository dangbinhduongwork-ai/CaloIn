import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../foods/data/food_repository_provider.dart';
import '../../../diary/data/diary_providers.dart';
import '../../../diary/domain/food_log_entry.dart';
import '../../../diary/domain/meal_type.dart';
import '../../../diary/presentation/widgets/food_portion_bottom_sheet.dart';

class MealSectionCard extends ConsumerWidget {
  const MealSectionCard({
    required this.mealType,
    required this.entries,
    required this.targetDate,
    super.key,
  });

  final MealType mealType;
  final List<FoodLogEntry> entries;
  final DateTime targetDate;

  String _getMealName(BuildContext context, MealType type) {
    final l10n = AppLocalizations.of(context);
    return switch (type) {
      MealType.breakfast => l10n.breakfast,
      MealType.lunch => l10n.lunch,
      MealType.dinner => l10n.dinner,
      MealType.snack => l10n.snack,
    };
  }

  IconData _getMealIcon(MealType type) {
    return switch (type) {
      MealType.breakfast => Icons.wb_sunny_outlined,
      MealType.lunch => Icons.wb_twilight_outlined,
      MealType.dinner => Icons.nights_stay_outlined,
      MealType.snack => Icons.cookie_outlined,
    };
  }

  double get _totalKcal {
    double sum = 0.0;
    for (final e in entries) {
      sum += e.nutrition.kcal;
    }
    return sum;
  }

  Future<void> _copyFromYesterday(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final yesterday = targetDate.subtract(const Duration(days: 1));
    final repo = ref.read(foodLogRepositoryProvider);

    final count = await repo.copyMeal(yesterday, mealType, targetDate);

    if (context.mounted) {
      if (count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã sao chép $count món từ hôm qua')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noYesterdayItems)),
        );
      }
    }
  }

  Future<void> _editEntry(BuildContext context, WidgetRef ref, FoodLogEntry entry) async {
    if (entry.foodId != null) {
      final foodRepo = ref.read(foodRepositoryProvider);
      final food = await foodRepo.getFoodById(entry.foodId!);
      if (food != null && context.mounted) {
        await FoodPortionBottomSheet.show(
          context: context,
          food: food,
          mealType: entry.mealType,
          targetDate: entry.loggedAt,
          existingEntry: entry,
        );
        return;
      }
    }

    if (context.mounted) {
      _showQuickEntryOptions(context, ref, entry);
    }
  }

  Future<void> _showQuickEntryOptions(BuildContext context, WidgetRef ref, FoodLogEntry entry) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.foodNameSnapshot,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  AppFormatters.formatKcalWithUnit(entry.nutrition.kcal),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Đạm: ${entry.nutrition.protein.toStringAsFixed(1)}g • Carb: ${entry.nutrition.carb.toStringAsFixed(1)}g • Béo: ${entry.nutrition.fat.toStringAsFixed(1)}g',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Xóa khẩu phần này'),
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteEntryWithUndo(context, ref, entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEntryWithUndo(BuildContext context, WidgetRef ref, FoodLogEntry entry) async {
    final repo = ref.read(foodLogRepositoryProvider);
    await repo.delete(entry.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${entry.foodNameSnapshot}'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            textColor: AppColors.primaryContainer,
            onPressed: () async {
              await repo.add(entry);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealTitle = _getMealName(context, mealType);
    final mealIcon = _getMealIcon(mealType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal Header Row
            Row(
              children: [
                Icon(mealIcon, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  mealTitle,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_totalKcal.round()} kcal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 4),

                // Add button for this meal
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                  tooltip: 'Thêm món',
                  onPressed: () {
                    context.push('/diary/add?mealType=${mealType.name}');
                  },
                ),

                // Meal menu (Copy yesterday)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (val) {
                    if (val == 'copy') {
                      _copyFromYesterday(context, ref);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          const Icon(Icons.copy_rounded, size: 18),
                          const SizedBox(width: 10),
                          Text(l10n.copyYesterdayMeal),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (entries.isEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  'Chưa có món ăn nào • Nhấn + để ghi',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ] else ...[
              const Divider(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Dismissible(
                    key: Key(entry.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Xóa',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (_) {
                      _deleteEntryWithUndo(context, ref, entry);
                    },
                    child: InkWell(
                      onTap: () => _editEntry(context, ref, entry),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.foodNameSnapshot,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.isQuickAdd
                                        ? 'Thêm nhanh calo'
                                        : '${entry.grams?.round() ?? 0}g • P:${entry.nutrition.protein.toStringAsFixed(1)}g C:${entry.nutrition.carb.toStringAsFixed(1)}g F:${entry.nutrition.fat.toStringAsFixed(1)}g',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              AppFormatters.formatKcalWithUnit(entry.nutrition.kcal),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 18,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _editEntry(context, ref, entry);
                                } else if (val == 'delete') {
                                  _deleteEntryWithUndo(context, ref, entry);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Sửa khẩu phần'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Xóa khẩu phần', style: TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
