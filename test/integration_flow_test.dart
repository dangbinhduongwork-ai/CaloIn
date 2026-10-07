import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/core/database/app_database.dart';
import 'package:caloin/core/database/database_provider.dart';
import 'package:caloin/core/theme/theme_provider.dart';
import 'package:caloin/features/foods/data/food_repository_impl.dart';
import 'package:caloin/features/foods/data/food_repository_provider.dart';
import 'package:caloin/main.dart';

void main() {
  testWidgets('End-to-End Flow: Onboarding -> Log a meal -> Dashboard verifies kcal -> History view', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final foodRepo = FoodRepositoryImpl(db: db, prefs: prefs);

    // Seed test foods
    await foodRepo.seedFoods([
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
    ], version: 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
          foodRepositoryProvider.overrideWithValue(foodRepo),
        ],
        child: const CaloInApp(),
      ),
    );

    await tester.pumpAndSettle();

    // ==========================================
    // 1. ONBOARDING
    // ==========================================
    expect(find.text('Giới tính & Tuổi'), findsOneWidget);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(find.text('Chiều cao & Cân nặng'), findsOneWidget);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(find.text('Mức độ vận động'), findsOneWidget);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(find.text('Mục tiêu cân nặng'), findsOneWidget);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    expect(find.text('Chỉ số năng lượng ước tính'), findsOneWidget);
    expect(find.text('Bắt đầu sử dụng'), findsOneWidget);
    await tester.tap(find.text('Bắt đầu sử dụng'));
    await tester.pumpAndSettle();

    // ==========================================
    // 2. DASHBOARD
    // ==========================================
    expect(find.text('Hôm nay'), findsWidgets);
    expect(find.text('Bữa sáng'), findsOneWidget);

    // Tap + button on Breakfast to log a meal
    final addBreakfastButton = find.byKey(const Key('add_meal_breakfast'));
    expect(addBreakfastButton, findsOneWidget);
    await tester.tap(addBreakfastButton);
    await tester.pumpAndSettle();

    // ==========================================
    // 3. SEARCH & LOG FOOD
    // ==========================================
    expect(find.text('Ghi món vào nhật ký'), findsOneWidget);

    // Switch to "Tất cả" tab
    await tester.tap(find.text('Tất cả'));
    await tester.pumpAndSettle();

    // Select "Phở bò"
    expect(find.text('Phở bò'), findsOneWidget);
    await tester.tap(find.text('Phở bò'));
    await tester.pumpAndSettle();

    // Food portion bottom sheet opens: 500g -> 525 kcal
    expect(find.text('525 kcal'), findsOneWidget);
    final confirmAddButton = find.text('Thêm vào nhật ký');
    expect(confirmAddButton, findsOneWidget);
    await tester.tap(confirmAddButton);
    await tester.pumpAndSettle();

    // Back to Dashboard: verify kcal is now 525!
    expect(find.text('525'), findsWidgets);
    expect(find.text('Phở bò'), findsOneWidget);

    // ==========================================
    // 4. HISTORY VIEW
    // ==========================================
    // Tap History navigation tab (index 1)
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    // History screen loads
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Tuần'), findsOneWidget);
    expect(find.text('Chi tiết từng ngày'), findsOneWidget);

    // Verifies 525 kcal is tracked in History
    expect(find.text('525 kcal'), findsWidgets);
    expect(find.text('1 / 7 ngày'), findsOneWidget);
  });
}
