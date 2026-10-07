import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caloin/main.dart';
import 'package:caloin/core/theme/theme_provider.dart';

void main() {
  testWidgets('CaloInApp loads and displays dashboard screen when profile exists', (WidgetTester tester) async {
    final mockProfileJson = json.encode({
      'gender': 'male',
      'age': 25,
      'heightCm': 175.0,
      'weightKg': 70.0,
      'activityLevel': 'moderate',
      'goal': 'maintain',
      'dailyGoalKcal': 2560,
      'isGoalManual': false,
      'macroSplit': {
        'proteinPct': 20,
        'carbPct': 50,
        'fatPct': 30,
      },
    });

    SharedPreferences.setMockInitialValues({
      'user_profile_json': mockProfileJson,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const CaloInApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CaloIn'), findsOneWidget);
    expect(find.text('Hôm nay'), findsWidgets);
    expect(find.text('Món ăn'), findsOneWidget);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.textContaining('2560 kcal'), findsOneWidget);
  });
}
