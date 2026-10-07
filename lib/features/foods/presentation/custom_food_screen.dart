import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../data/food_repository_provider.dart';
import '../domain/barcode_product.dart';
import '../domain/food.dart';
import '../domain/food_validator.dart';
import '../../profile/domain/macro_calculator.dart';

class CustomFoodScreen extends ConsumerStatefulWidget {
  const CustomFoodScreen({this.initialBarcodeProduct, super.key});

  final BarcodeProduct? initialBarcodeProduct;

  @override
  ConsumerState<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends ConsumerState<CustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameViController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();
  final _servingGramsController = TextEditingController(text: '100');

  String _selectedCategory = 'other';
  String _selectedServingLabel = 'portion';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final p = widget.initialBarcodeProduct;
    if (p != null) {
      _nameViController.text = p.displayName;
      _nameEnController.text = p.displayName;
      _kcalController.text = p.kcalPer100g > 0 ? p.kcalPer100g.toString() : '';
      _proteinController.text = p.proteinPer100g > 0 ? p.proteinPer100g.toString() : '';
      _carbController.text = p.carbPer100g > 0 ? p.carbPer100g.toString() : '';
      _fatController.text = p.fatPer100g > 0 ? p.fatPer100g.toString() : '';
      _servingGramsController.text =
          p.defaultServingGrams > 0 ? p.defaultServingGrams.round().toString() : '100';
      _selectedServingLabel = p.servingLabel;
    }
  }

  @override
  void dispose() {
    _nameViController.dispose();
    _nameEnController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    _servingGramsController.dispose();
    super.dispose();
  }

  double get _currentEstimatedKcal {
    final p = double.tryParse(_proteinController.text) ?? 0.0;
    final c = double.tryParse(_carbController.text) ?? 0.0;
    final f = double.tryParse(_fatController.text) ?? 0.0;
    return MacroCalculator.calculateKcalFromMacros(
      proteinGrams: p,
      carbGrams: c,
      fatGrams: f,
    );
  }

  void _onMacroChanged() {
    setState(() {});
  }

  Future<void> _submitForm() async {
    setState(() => _errorMessage = null);

    final nameVi = _nameViController.text.trim();
    final nameEn = _nameEnController.text.trim();
    final kcal = double.tryParse(_kcalController.text);
    final protein = double.tryParse(_proteinController.text);
    final carb = double.tryParse(_carbController.text);
    final fat = double.tryParse(_fatController.text);
    final servingGrams = double.tryParse(_servingGramsController.text) ?? 100.0;

    final validation = FoodValidator.validateCustomFood(
      name: nameVi,
      kcalPer100g: kcal ?? -1,
      proteinPer100g: protein ?? -1,
      carbPer100g: carb ?? -1,
      fatPer100g: fat ?? -1,
    );

    if (!validation.isValid) {
      setState(() {
        _errorMessage = validation.errorMessage;
      });
      return;
    }

    final newFood = Food(
      id: '',
      nameVi: nameVi,
      nameEn: nameEn.isEmpty ? nameVi : nameEn,
      kcalPer100g: kcal!,
      proteinPer100g: protein!,
      carbPer100g: carb!,
      fatPer100g: fat!,
      defaultServingGrams: servingGrams,
      servingLabelKey: _selectedServingLabel,
      category: _selectedCategory,
      isCustom: true,
      dataQuality: widget.initialBarcodeProduct != null ? 'community' : 'custom',
    );

    final repo = ref.read(foodRepositoryProvider);
    final savedFood = await repo.addCustomFood(newFood);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.foodAddedSuccess)),
      );
      context.pop(savedFood);
    }
  }

  String _getCategoryName(BuildContext context, String categoryKey) {
    final l10n = AppLocalizations.of(context);
    return switch (categoryKey) {
      'carb' => l10n.categoryCarb,
      'meat' => l10n.categoryMeat,
      'fish_seafood' => l10n.categoryFishSeafood,
      'egg_dairy' => l10n.categoryEggDairy,
      'vegetable' => l10n.categoryVegetable,
      'fruit' => l10n.categoryFruit,
      'drink' => l10n.categoryDrink,
      'snack' => l10n.categorySnack,
      _ => l10n.categoryOther,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estimatedKcal = _currentEstimatedKcal;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCustomFood),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Food Name
              Text(l10n.customFoodName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameViController,
                decoration: const InputDecoration(hintText: 'VD: Cơm chiên dưa bò'),
              ),
              const SizedBox(height: 16),

              // Category & Serving Unit Dropdowns
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: [
                            'carb', 'meat', 'fish_seafood', 'egg_dairy',
                            'vegetable', 'fruit', 'drink', 'snack', 'other'
                          ].map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                _getCategoryName(context, cat),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đơn vị tính',
                          style: TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedServingLabel,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: ['portion', 'bowl', 'plate', 'piece', 'cup', 'can'].map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(
                                _getServingUnitLabel(context, unit),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedServingLabel = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kcal per 100g
              Text(l10n.kcalPer100g, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kcalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'VD: 165'),
              ),
              const SizedBox(height: 16),

              // Macro Fields
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đạm (P/100g)', style: TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _proteinController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _onMacroChanged(),
                          decoration: const InputDecoration(hintText: 'g'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Carb (C/100g)', style: TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _carbController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _onMacroChanged(),
                          decoration: const InputDecoration(hintText: 'g'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Béo (F/100g)', style: TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _fatController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => _onMacroChanged(),
                          decoration: const InputDecoration(hintText: 'g'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Cross-check info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.estimatedFromMacros(AppFormatters.formatKcal(estimatedKcal)),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Default Serving Grams
              Text(l10n.defaultServing, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _servingGramsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: '100'),
              ),
              const SizedBox(height: 24),

              // Submit Button
              FilledButton(
                onPressed: _submitForm,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
