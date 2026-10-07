import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/food_search_view.dart';

class FoodLibraryScreen extends ConsumerWidget {
  const FoodLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navFoods,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const FoodSearchView(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addCustomFood),
        onPressed: () {
          context.push('/foods/custom');
        },
      ),
    );
  }
}
