import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/core/database/app_database.dart';
import 'package:caloin/core/database/database_provider.dart';
import 'package:caloin/core/theme/theme_provider.dart';
import 'package:caloin/features/diary/data/diary_providers.dart';
import 'package:caloin/features/diary/data/food_log_repository_impl.dart';
import 'package:caloin/features/diary/domain/food_log_entry.dart';
import 'package:caloin/features/diary/domain/meal_type.dart';
import 'package:caloin/features/foods/domain/nutrition.dart';
import 'package:caloin/features/history/data/history_providers.dart';
import 'package:caloin/features/history/presentation/history_screen.dart';
import 'package:caloin/features/profile/data/profile_providers.dart';
import 'package:caloin/features/profile/domain/profile_enums.dart';
import 'package:caloin/features/profile/domain/user_profile.dart';
import 'package:caloin/l10n/app_localizations.dart';

void main() {
  testWidgets('HistoryScreen: chuyển Ngày/Tuần/Tháng và hiển thị empty state khi chưa có dữ liệu', (tester) async {
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
          home: HistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Segmented Buttons
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Ngày'), findsOneWidget);
    expect(find.text('Tuần'), findsOneWidget);
    expect(find.text('Tháng'), findsOneWidget);

    // Empty state message when there are no logs in the period
    expect(find.text('Không có dữ liệu trong khoảng thời gian này'), findsOneWidget);

    // Switch to 'Ngày'
    await tester.tap(find.text('Ngày'));
    await tester.pumpAndSettle();
    expect(find.text('Ngày này chưa có bản ghi dinh dưỡng nào.'), findsOneWidget);

    // Switch to 'Tháng'
    await tester.tap(find.text('Tháng'));
    await tester.pumpAndSettle();
    expect(find.text('Không có dữ liệu trong khoảng thời gian này'), findsOneWidget);
  });

  testWidgets('HistoryScreen: nút "Sau" bị khóa (disabled) ở thời điểm hiện tại, mở khi lùi về quá khứ', (tester) async {
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
          home: HistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final nextButtonFinder = find.byKey(const Key('history_next_button'));
    final prevButtonFinder = find.byKey(const Key('history_prev_button'));

    expect(nextButtonFinder, findsOneWidget);
    expect(prevButtonFinder, findsOneWidget);

    // At current week, next button MUST be disabled (onPressed == null)
    var nextButton = tester.widget<IconButton>(nextButtonFinder);
    expect(nextButton.onPressed, isNull);

    // Tap Prev button to go to previous week
    await tester.tap(prevButtonFinder);
    await tester.pumpAndSettle();

    // Now we are in the past, so next button MUST be enabled
    nextButton = tester.widget<IconButton>(nextButtonFinder);
    expect(nextButton.onPressed, isNotNull);

    // Tap Next button to return to current week
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    // Next button is disabled again!
    nextButton = tester.widget<IconButton>(nextButtonFinder);
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('HistoryScreen: chạm vào một ngày cập nhật selectedDateProvider và chuyển sang tab Hôm nay', (tester) async {
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

    // Add entry for today
    final today = DateTime.now();
    await logRepo.add(
      FoodLogEntry(
        id: 'test_hist_today',
        foodNameSnapshot: 'Phở bò tái',
        mealType: MealType.breakfast,
        grams: 500,
        nutrition: const Nutrition(kcal: 525, protein: 28, carb: 75, fat: 13),
        loggedAt: today,
      ),
    );

    DateTime? capturedSelectedDate;

    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Today Tab Screen')),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        foodLogRepositoryProvider.overrideWithValue(logRepo),
        profileProvider.overrideWith(() => _MockProfileNotifier(testProfile)),
      ],
    );
    addTearDown(container.dispose);

    container.listen(selectedDateProvider, (previous, next) {
      capturedSelectedDate = next;
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify statistics and Phở bò entry appear
    expect(find.text('525 kcal'), findsWidgets);
    expect(find.text('Chi tiết từng ngày'), findsOneWidget);

    // Tap on the day item in the list
    final dayTile = find.byType(ListTile).first;
    expect(dayTile, findsOneWidget);
    await tester.tap(dayTile);
    await tester.pumpAndSettle();

    // Verify selectedDate was updated to today's date
    expect(capturedSelectedDate, isNotNull);
    expect(capturedSelectedDate!.year, equals(today.year));
    expect(capturedSelectedDate!.month, equals(today.month));
    expect(capturedSelectedDate!.day, equals(today.day));

    // And router navigated to Today tab ('/')
    expect(find.text('Today Tab Screen'), findsOneWidget);
  });
}

class _MockProfileNotifier extends ProfileNotifier {
  _MockProfileNotifier(this._initial);
  final UserProfile _initial;

  @override
  Future<UserProfile?> build() async => _initial;
}
