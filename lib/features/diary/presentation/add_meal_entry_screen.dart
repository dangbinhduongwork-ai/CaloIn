import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../foods/data/food_repository_provider.dart';
import '../../foods/domain/food.dart';
import '../../foods/presentation/widgets/food_search_view.dart';
import '../data/diary_providers.dart';
import '../domain/meal_type.dart';
import 'widgets/food_portion_bottom_sheet.dart';

class AddMealEntryScreen extends ConsumerStatefulWidget {
  const AddMealEntryScreen({this.initialMealType, super.key});

  final String? initialMealType;

  @override
  ConsumerState<AddMealEntryScreen> createState() => _AddMealEntryScreenState();
}

class _AddMealEntryScreenState extends ConsumerState<AddMealEntryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MealType _selectedMeal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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
    _tabController.dispose();
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

  void _onFoodTapped(Food food) {
    final targetDate = ref.read(effectiveDateProvider);
    FoodPortionBottomSheet.show(
      context: context,
      food: food,
      mealType: _selectedMeal,
      targetDate: targetDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi ${_getMealName(context, _selectedMeal)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: l10n.scanBarcode,
            onPressed: () async {
              final result = await context.push<Food>('/foods/scan');
              if (result != null && mounted) {
                _onFoodTapped(result);
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.flash_on_rounded, size: 18),
            label: Text(l10n.quickAddCalories),
            onPressed: () {
              context.push('/diary/quick-add?mealType=${_selectedMeal.name}');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? Colors.white : AppColors.primaryDark,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: l10n.recentFoods),
            Tab(text: l10n.favoriteFoods),
            Tab(text: l10n.allFoods),
          ],
        ),
      ),
      body: Column(
        children: [
          // Meal Selector Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight.withAlpha(128),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (int i = 0; i < MealType.values.length; i++) ...[
                    ChoiceChip(
                      showCheckmark: false,
                      label: Text(_getMealName(context, MealType.values[i])),
                      selected: _selectedMeal == MealType.values[i],
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMeal = MealType.values[i]);
                      },
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        fontWeight: _selectedMeal == MealType.values[i] ? FontWeight.bold : FontWeight.w500,
                        color: _selectedMeal == MealType.values[i] ? AppColors.primaryDark : null,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (i < MealType.values.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Recent Foods Tab
                _buildRecentTab(),

                // 2. Favorite Foods Tab
                _buildFavoritesTab(),

                // 3. All Foods (Search view)
                FoodSearchView(
                  showFavoriteToggle: true,
                  onFoodSelected: _onFoodTapped,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTab() {
    final recentAsync = ref.watch(recentFoodsFutureProvider);

    return recentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (err, _) => Center(child: Text('Lỗi: $err')),
      data: (foods) {
        if (foods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  'Chưa có món ăn nào trong lịch sử gần đây',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: foods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final food = foods[index];
            return _buildFoodTile(food);
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    final favAsync = ref.watch(favoriteFoodsStreamProvider);

    return favAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (err, _) => Center(child: Text('Lỗi: $err')),
      data: (foods) {
        if (foods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  'Chưa có món ăn yêu thích nào',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: foods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final food = foods[index];
            return _buildFoodTile(food);
          },
        );
      },
    );
  }

  Widget _buildFoodTile(Food food) {
    return Card(
      child: ListTile(
        title: Text(food.nameVi, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${food.kcalPer100g.round()} kcal / 100g • ${food.defaultServingGrams.round()}g',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
        onTap: () => _onFoodTapped(food),
      ),
    );
  }
}
