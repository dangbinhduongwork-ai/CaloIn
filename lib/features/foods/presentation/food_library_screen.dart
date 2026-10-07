import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../data/food_repository_provider.dart';
import '../domain/food.dart';
import 'widgets/food_search_view.dart';

class FoodLibraryScreen extends ConsumerWidget {
  const FoodLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.navFoods,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              tooltip: l10n.scanBarcode,
              onPressed: () => context.push('/foods/scan'),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Món tùy chỉnh'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const FoodSearchView(),
            _CustomFoodsListView(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.addCustomFood),
          onPressed: () {
            context.push('/foods/custom');
          },
        ),
      ),
    );
  }
}

class _CustomFoodsListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customFoodsAsync = ref.watch(customFoodsStreamProvider);

    return customFoodsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Lỗi: $err'),
      ),
      data: (foods) {
        if (foods.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có món tùy chỉnh nào',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn có thể tạo món ăn của riêng mình với thông tin calo và macro tùy chọn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => context.push('/foods/custom'),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addCustomFood),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: foods.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          itemBuilder: (context, index) {
            final food = foods[index];
            return _CustomFoodTile(food: food);
          },
        );
      },
    );
  }
}

class _CustomFoodTile extends ConsumerWidget {
  const _CustomFoodTile({required this.food});

  final Food food;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa món tùy chỉnh?'),
        content: Text('Bạn có chắc chắn muốn xóa "${food.displayName('vi')}"? Các nhật ký đã ghi trước đây vẫn giữ nguyên thông tin calo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(foodRepositoryProvider).deleteCustomFood(food.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa món ${food.displayName('vi')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryContainer,
        child: const Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 20),
      ),
      title: Text(
        food.displayName(locale),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          '100g: ${AppFormatters.formatKcal(food.kcalPer100g)} • '
          'P: ${food.proteinPer100g.round()}g • '
          'C: ${food.carbPer100g.round()}g • '
          'F: ${food.fatPer100g.round()}g',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
        tooltip: 'Xóa món',
        onPressed: () => _confirmDelete(context, ref),
      ),
    );
  }
}
