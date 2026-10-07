import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/food_repository_provider.dart';
import '../../domain/food.dart';

class FoodSearchView extends ConsumerStatefulWidget {
  const FoodSearchView({
    this.onFoodSelected,
    this.showFavoriteToggle = true,
    super.key,
  });

  final void Function(Food food)? onFoodSelected;
  final bool showFavoriteToggle;

  @override
  ConsumerState<FoodSearchView> createState() => _FoodSearchViewState();
}

class _FoodSearchViewState extends ConsumerState<FoodSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _currentQuery = '';
  String _selectedCategory = 'all';
  List<Food> _foods = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'all',
    'carb',
    'meat',
    'fish_seafood',
    'egg_dairy',
    'vegetable',
    'fruit',
    'drink',
    'snack',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _currentQuery = value;
        });
        _fetchFoods();
      }
    });
  }

  Future<void> _fetchFoods() async {
    setState(() => _isLoading = true);
    final repo = ref.read(foodRepositoryProvider);
    final results = await repo.search(
      _currentQuery,
      category: _selectedCategory == 'all' ? null : _selectedCategory,
    );
    if (mounted) {
      setState(() {
        _foods = results;
        _isLoading = false;
      });
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
      'other' => l10n.categoryOther,
      _ => l10n.categoryAll,
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

    return Column(
      children: [
        // Search Input Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.foodSearchPlaceholder,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Category Filter Chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(_getCategoryName(context, cat)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = cat);
                    _fetchFoods();
                  }
                },
                selectedColor: AppColors.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.primaryDark)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Food List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : _foods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noFoodsFound,
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: _foods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final food = _foods[index];
                        return _buildFoodCard(context, food);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFoodCard(BuildContext context, Food food) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unitLabel = _getServingUnitLabel(context, food.servingLabelKey);

    return InkWell(
      onTap: widget.onFoodSelected != null ? () => widget.onFoodSelected!(food) : null,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            food.nameVi,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (food.isCustom) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Custom',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${food.kcalPer100g.round()} kcal / 100g • ${food.defaultServingGrams.round()}g (1 $unitLabel)',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Macro badges
                    Row(
                      children: [
                        _buildMacroBadge(
                          label: 'P ${food.proteinPer100g.toStringAsFixed(1)}g',
                          color: AppColors.protein,
                          bgColor: AppColors.proteinLight,
                        ),
                        const SizedBox(width: 6),
                        _buildMacroBadge(
                          label: 'C ${food.carbPer100g.toStringAsFixed(1)}g',
                          color: AppColors.carb,
                          bgColor: AppColors.carbLight,
                        ),
                        const SizedBox(width: 6),
                        _buildMacroBadge(
                          label: 'F ${food.fatPer100g.toStringAsFixed(1)}g',
                          color: AppColors.fat,
                          bgColor: AppColors.fatLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.showFavoriteToggle)
                IconButton(
                  icon: Icon(
                    food.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: food.isFavorite ? Colors.redAccent : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                  onPressed: () async {
                    await ref.read(foodRepositoryProvider).toggleFavorite(food.id);
                    await _fetchFoods();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroBadge({
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
