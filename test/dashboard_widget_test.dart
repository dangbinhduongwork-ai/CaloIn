import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/core/database/app_database.dart';
import 'package:caloin/core/database/database_provider.dart';
import 'package:caloin/core/theme/theme_provider.dart';
import 'package:caloin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:caloin/features/diary/data/diary_providers.dart';
import 'package:caloin/features/diary/data/food_log_repository_impl.dart';
import 'package:caloin/features/diary/domain/food_log_entry.dart';
import 'package:caloin/features/diary/domain/meal_type.dart';
import 'package:caloin/features/diary/presentation/widgets/food_portion_bottom_sheet.dart';
import 'package:caloin/features/foods/domain/food.dart';
import 'package:caloin/features/foods/domain/nutrition.dart';
import 'package:caloin/features/profile/data/profile_providers.dart';
import 'package:caloin/features/profile/domain/macro_split.dart';
import 'package:caloin/features/profile/domain/profile_enums.dart';
import 'package:caloin/features/profile/domain/user_profile.dart';
import 'package:caloin/l10n/app_localizations.dart';

void main() {
  testWidgets('FoodPortionBottomSheet: changing grams updates preview kcal and macros in real-time', (tester) async {
    const food = Food(
      id: '1',
      nameVi: 'Cơm trắng',
      nameEn: 'White Rice',
      kcalPer100g: 130.0,
      proteinPer100g: 2.7,
      carbPer100g: 28.0,
      fatPer100g: 0.3,
      defaultServingGrams: 150.0,
      servingLabelKey: 'bowl',
      category: 'carb',
    );

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: FoodPortionBottomSheet(
              food: food,
              mealType: MealType.lunch,
              targetDate: DateTime(2026, 10, 7),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Default grams is 150g -> 130 * 1.5 = 195 kcal
    expect(find.text('195 kcal'), findsOneWidget);

    // Tap quick chip 100g
    final chip100 = find.text('100g');
    expect(chip100, findsOneWidget);
    await tester.tap(chip100);
    await tester.pumpAndSettle();

    // Now kcal preview should be 130 kcal!
    expect(find.text('130 kcal'), findsOneWidget);
    expect(find.text('2.7 g'), findsOneWidget); // Protein for 100g
    expect(find.text('28.0 g'), findsOneWidget); // Carb for 100g
  });

  testWidgets('DashboardScreen: shows items, swipe to delete, and undo recovers item', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final logRepo = FoodLogRepositoryImpl(db);

    const testProfile = UserProfile(
      gender: Gender.male,
      age: 25,
      heightCm: 170.0,
      weightKg: 65.0,
      activityLevel: ActivityLevel.moderate,
      goal: Goal.maintain,
      dailyGoalKcal: 2000,
    );

    final today = DateTime.now();

    // Add 1 breakfast item
    await logRepo.add(
      FoodLogEntry(
        id: 'entry_test_1',
        foodId: '1',
        foodNameSnapshot: 'Bánh mì ốp la',
        mealType: MealType.breakfast,
        grams: 160,
        nutrition: const Nutrition(kcal: 370, protein: 14, carb: 48, fat: 14),
        loggedAt: today,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          foodLogRepositoryProvider.overrideWithValue(logRepo),
          profileProvider.overrideWith(() => _MockProfileNotifier(testProfile)),
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
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify item is displayed
    expect(find.text('Bánh mì ốp la'), findsOneWidget);
    expect(find.text('370 kcal'), findsWidgets);

    // Swipe dismiss to delete
    await tester.drag(find.text('Bánh mì ốp la'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Item should be gone and Undo SnackBar appears
    expect(find.text('Bánh mì ốp la'), findsNothing);
    expect(find.text('Hoàn tác'), findsOneWidget);

    // Tap Undo
    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();

    // Item is restored!
    expect(find.text('Bánh mì ốp la'), findsOneWidget);
  });

  testWidgets('DashboardScreen: when calories exceed target, uses neutral wording without alarm red', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final logRepo = FoodLogRepositoryImpl(db);

    const testProfile = UserProfile(
      gender: Gender.male,
      age: 25,
      heightCm: 170.0,
      weightKg: 65.0,
      activityLevel: ActivityLevel.sedentary,
      goal: Goal.maintain,
      dailyGoalKcal: 1800,
    );

    final today = DateTime.now();

    // Add entry with 2000 kcal (exceeds 1800 by 200 kcal)
    await logRepo.add(
      FoodLogEntry(
        id: 'entry_exceed',
        foodNameSnapshot: 'Bữa tiệc lớn',
        mealType: MealType.dinner,
        grams: null,
        nutrition: const Nutrition(kcal: 2000, protein: 90, carb: 220, fat: 80),
        isQuickAdd: true,
        loggedAt: today,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          foodLogRepositoryProvider.overrideWithValue(logRepo),
          profileProvider.overrideWith(() => _MockProfileNotifier(testProfile)),
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
          home: DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify neutral phrasing: "Đã vượt 200 kcal"
    expect(find.text('Đã vượt 200 kcal'), findsOneWidget);
    expect(find.text('2000'), findsOneWidget);
  });
}

class _MockProfileNotifier extends ProfileNotifier {
  _MockProfileNotifier(this._initial);
  final UserProfile _initial;

  @override
  Future<UserProfile?> build() async => _initial;
}
