import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../foods/domain/food.dart';
import '../../../foods/domain/food_nutrition_calculator.dart';
import '../../data/diary_providers.dart';
import '../../domain/food_log_entry.dart';
import '../../domain/meal_type.dart';

enum PortionInputMode {
  grams,
  servings,
}

class FoodPortionBottomSheet extends ConsumerStatefulWidget {
  const FoodPortionBottomSheet({
    required this.food,
    required this.mealType,
    required this.targetDate,
    this.existingEntry,
    super.key,
  });

  final Food food;
  final MealType mealType;
  final DateTime targetDate;
  final FoodLogEntry? existingEntry;

  static Future<void> show({
    required BuildContext context,
    required Food food,
    required MealType mealType,
    required DateTime targetDate,
    FoodLogEntry? existingEntry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FoodPortionBottomSheet(
        food: food,
        mealType: mealType,
        targetDate: targetDate,
        existingEntry: existingEntry,
      ),
    );
  }

  @override
  ConsumerState<FoodPortionBottomSheet> createState() => _FoodPortionBottomSheetState();
}

class _FoodPortionBottomSheetState extends ConsumerState<FoodPortionBottomSheet> {
  late MealType _selectedMeal;
  late PortionInputMode _mode;
  late double _grams;
  late double _servingMultiplier;
  late TextEditingController _gramsController;

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.existingEntry?.mealType ?? widget.mealType;
    _mode = PortionInputMode.grams;

    _grams = widget.existingEntry?.grams ?? widget.food.defaultServingGrams;
    if (_grams <= 0) _grams = 100.0;

    _servingMultiplier = widget.food.defaultServingGrams > 0
        ? (_grams / widget.food.defaultServingGrams)
        : 1.0;
    // Round to nearest 0.5
    _servingMultiplier = (_servingMultiplier * 2).round() / 2;
    if (_servingMultiplier <= 0) _servingMultiplier = 1.0;

    _gramsController = TextEditingController(text: _grams.round().toString());
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _onGramsInputChanged(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null && parsed > 0) {
      setState(() {
        _grams = parsed;
        if (widget.food.defaultServingGrams > 0) {
          _servingMultiplier = (_grams / widget.food.defaultServingGrams);
        }
      });
    }
  }

  void _setQuickGrams(double grams) {
    setState(() {
      _grams = grams;
      _gramsController.text = grams.round().toString();
      if (widget.food.defaultServingGrams > 0) {
        _servingMultiplier = (grams / widget.food.defaultServingGrams);
      }
    });
  }

  void _changeServingMultiplier(double delta) {
    final newMultiplier = (_servingMultiplier + delta);
    if (newMultiplier >= 0.5 && newMultiplier <= 20.0) {
      setState(() {
        _servingMultiplier = newMultiplier;
        _grams = newMultiplier * widget.food.defaultServingGrams;
        _gramsController.text = _grams.round().toString();
      });
    }
  }

  String _getMealName(BuildContext context, MealType type) {
    final l10n = AppLocalizations.of(context);
    return switch (type) {
      MealType.breakfast => l10n.breakfast,
      MealType.lunch => l10n.lunch,
      MealType.dinner => l10n.dinner,
      MealType.snack => l10n.snack,
    };
  }

  String _getServingUnitLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'bowl' => l10n.servingUnitBowl,
      'plate' => l10n.servingUnitPlate,
      'piece' => l10n.servingUnitPiece,
      'cup' => l10n.servingUnitCup,
      'portion' => l10n.servingUnitPortion,
      'can' => l10n.servingUnitCan,
      _ => key,
    };
  }

  Future<void> _saveEntry() async {
    final repo = ref.read(foodLogRepositoryProvider);
    final nutrition = FoodNutritionCalculator.calculate(
      food: widget.food,
      grams: _grams,
    );

    if (widget.existingEntry != null) {
      final updated = widget.existingEntry!.copyWith(
        mealType: _selectedMeal,
        grams: _grams,
        nutrition: nutrition,
      );
      await repo.update(updated);
    } else {
      final newId = 'entry_${DateTime.now().microsecondsSinceEpoch}';
      final entry = FoodLogEntry(
        id: newId,
        foodId: widget.food.id,
        foodNameSnapshot: widget.food.nameVi,
        mealType: _selectedMeal,
        grams: _grams,
        nutrition: nutrition,
        isQuickAdd: false,
        loggedAt: DateTime(
          widget.targetDate.year,
          widget.targetDate.month,
          widget.targetDate.day,
          DateTime.now().hour,
          DateTime.now().minute,
        ),
      );
      await repo.add(entry);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingEntry != null
                ? 'Đã cập nhật khẩu phần'
                : 'Đã thêm ${widget.food.nameVi} vào ${_getMealName(context, _selectedMeal)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmDeleteEntry() async {
    final entry = widget.existingEntry;
    if (entry == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khẩu phần?'),
        content: Text('Bạn có chắc chắn muốn xóa "${entry.foodNameSnapshot}" khỏi ${_getMealName(context, _selectedMeal)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(foodLogRepositoryProvider);
      await repo.delete(entry.id);

      if (mounted) {
        Navigator.of(context).pop();
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nutrition = FoodNutritionCalculator.calculate(
      food: widget.food,
      grams: _grams,
    );
    final unitLabel = _getServingUnitLabel(context, widget.food.servingLabelKey);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Meal Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.food.nameVi,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.food.kcalPer100g.round()} kcal / 100g',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (widget.existingEntry != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'Xóa khẩu phần',
                  onPressed: _confirmDeleteEntry,
                ),
              // Meal Dropdown
              DropdownButton<MealType>(
                value: _selectedMeal,
                underline: const SizedBox.shrink(),
                items: MealType.values.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(_getMealName(context, m)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMeal = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Real-time Nutrition Preview Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Năng lượng', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatKcalWithUnit(nutrition.kcal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                _buildMacroPreviewStat('Đạm', nutrition.protein, AppColors.protein),
                _buildMacroPreviewStat('Carb', nutrition.carb, AppColors.carb),
                _buildMacroPreviewStat('Béo', nutrition.fat, AppColors.fat),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mode Segmented Button (Gram vs Khẩu phần)
          SegmentedButton<PortionInputMode>(
            segments: [
              const ButtonSegment(
                value: PortionInputMode.grams,
                label: Text('Theo Gram'),
                icon: Icon(Icons.scale_outlined, size: 16),
              ),
              ButtonSegment(
                value: PortionInputMode.servings,
                label: Text('Khẩu phần ($unitLabel)'),
                icon: const Icon(Icons.restaurant_outlined, size: 16),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (set) {
              setState(() => _mode = set.first);
            },
          ),
          const SizedBox(height: 16),

          // Input Body depending on Mode
          if (_mode == PortionInputMode.grams) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gramsController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onGramsInputChanged,
                    decoration: const InputDecoration(
                      suffixText: 'g',
                      hintText: 'Nhập số gram',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Quick gram chips: 50, 100, 150, 200
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [50.0, 100.0, 150.0, 200.0].map((quickG) {
                final isSelected = (_grams - quickG).abs() < 1.0;
                return ActionChip(
                  label: Text('${quickG.round()}g'),
                  backgroundColor: isSelected ? AppColors.primaryContainer : null,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                  ),
                  onPressed: () => _setQuickGrams(quickG),
                );
              }).toList(),
            ),
          ] else ...[
            // Servings stepper (+/- 0.5)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.remove_rounded),
                  onPressed: () => _changeServingMultiplier(-0.5),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        '${_servingMultiplier.toStringAsFixed(1)} $unitLabel',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '~${_grams.round()} g',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _changeServingMultiplier(0.5),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Confirm Action Button
          if (widget.existingEntry != null) ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _confirmDeleteEntry,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _grams > 0 ? _saveEntry : null,
                    child: const Text('Cập nhật khẩu phần', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else ...[
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _grams > 0 ? _saveEntry : null,
              child: Text(
                'Thêm vào ${_getMealName(context, _selectedMeal)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroPreviewStat(String title, double val, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          AppFormatters.formatMacroWithUnit(val),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
