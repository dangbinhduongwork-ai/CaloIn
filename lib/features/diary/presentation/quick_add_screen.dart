import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../foods/domain/nutrition.dart';
import '../data/diary_providers.dart';
import '../domain/diary_validator.dart';
import '../domain/food_log_entry.dart';
import '../domain/meal_type.dart';

class QuickAddScreen extends ConsumerStatefulWidget {
  const QuickAddScreen({this.initialMealType, super.key});

  final String? initialMealType;

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  late MealType _selectedMeal;
  final _nameController = TextEditingController(text: 'Món ăn thêm nhanh');
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialMealType != null) {
      _selectedMeal = MealType.values.firstWhere(
        (m) => m.name == widget.initialMealType,
        orElse: () => getDefaultMealTypeForTime(),
      );
    } else {
      _selectedMeal = getDefaultMealTypeForTime();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập tên món ăn');
      return;
    }

    final kcal = double.tryParse(_kcalController.text);
    final kcalValidation = DiaryValidator.validateQuickAddKcal(kcal);
    if (!kcalValidation.isValid) {
      setState(() => _errorMessage = kcalValidation.errorMessage);
      return;
    }

    final protein = double.tryParse(_proteinController.text) ?? 0.0;
    final carb = double.tryParse(_carbController.text) ?? 0.0;
    final fat = double.tryParse(_fatController.text) ?? 0.0;

    final targetDate = ref.read(effectiveDateProvider);
    final now = DateTime.now();

    final entry = FoodLogEntry(
      id: 'quick_${DateTime.now().microsecondsSinceEpoch}',
      foodId: null,
      foodNameSnapshot: name,
      mealType: _selectedMeal,
      grams: null,
      nutrition: Nutrition(
        kcal: kcal!,
        protein: protein,
        carb: carb,
        fat: fat,
      ),
      isQuickAdd: true,
      loggedAt: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        now.hour,
        now.minute,
      ),
    );

    await ref.read(foodLogRepositoryProvider).add(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${kcal.round()} kcal vào ${_getMealName(context, _selectedMeal)}'),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickAddCalories),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Meal Selector
            Text('Bữa ăn', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<MealType>(
              value: _selectedMeal,
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
            const SizedBox(height: 16),

            // Food Name / Description
            Text(l10n.quickAddName, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'VD: Ăn vặt, Tiệc buffet...'),
            ),
            const SizedBox(height: 16),

            // Calories (Required)
            const Text('Lượng Calo (kcal) *', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _kcalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Nhập số kcal (1 - 10000)',
                suffixText: 'kcal',
              ),
            ),
            const SizedBox(height: 20),

            // Optional Macros
            const Text(
              'Dinh dưỡng đa lượng (Tùy chọn)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Đạm (g)',
                      suffixText: 'g',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _carbController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Carb (g)',
                      suffixText: 'g',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Béo (g)',
                      suffixText: 'g',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            FilledButton(
              onPressed: _submit,
              child: const Text('Thêm vào nhật ký'),
            ),
          ],
        ),
      ),
    );
  }
}
