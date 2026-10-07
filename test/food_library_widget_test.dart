import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/core/database/app_database.dart';
import 'package:caloin/core/database/database_provider.dart';
import 'package:caloin/core/theme/theme_provider.dart';
import 'package:caloin/features/foods/data/food_repository_impl.dart';
import 'package:caloin/features/foods/data/food_repository_provider.dart';
import 'package:caloin/features/foods/presentation/food_library_screen.dart';
import 'package:caloin/l10n/app_localizations.dart';

void main() {
  testWidgets('FoodLibraryScreen: typing search query filters foods and tapping heart toggles favorite', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final db = AppDatabase(NativeDatabase.memory());
    final repo = FoodRepositoryImpl(db: db, prefs: prefs);

    await repo.seedFoods([
      {
        'seedKey': 'pho_bo',
        'nameVi': 'Phở bò',
        'nameEn': 'Beef Pho',
        'kcalPer100g': 105.0,
        'proteinPer100g': 5.5,
        'carbPer100g': 15.0,
        'fatPer100g': 2.5,
        'defaultServingGrams': 500.0,
        'servingLabelKey': 'bowl',
        'category': 'carb',
        'dataQuality': 'estimated',
      },
      {
        'seedKey': 'com_tam',
        'nameVi': 'Cơm tấm',
        'nameEn': 'Broken Rice',
        'kcalPer100g': 175.0,
        'proteinPer100g': 7.5,
        'carbPer100g': 23.5,
        'fatPer100g': 5.5,
        'defaultServingGrams': 350.0,
        'servingLabelKey': 'plate',
        'category': 'carb',
        'dataQuality': 'estimated',
      },
    ], version: 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          foodRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          locale: Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: FoodLibraryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Both foods are initially visible
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('Cơm tấm'), findsOneWidget);

    // Type "pho bo" into the search field
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'pho bo');

    // Wait for the 250ms debounce
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Only "Phở bò" should be displayed
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('Cơm tấm'), findsNothing);

    // Tap favorite heart icon
    final favoriteButton = find.byIcon(Icons.favorite_border_rounded);
    expect(favoriteButton, findsOneWidget);
    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();

    // Now heart icon turns solid red
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await db.close();
  });
}
