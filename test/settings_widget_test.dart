import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/core/database/app_database.dart';
import 'package:caloin/core/database/database_provider.dart';
import 'package:caloin/core/localization/locale_provider.dart';
import 'package:caloin/core/theme/theme_provider.dart';
import 'package:caloin/features/profile/data/profile_providers.dart';
import 'package:caloin/features/profile/domain/profile_enums.dart';
import 'package:caloin/features/profile/domain/user_profile.dart';
import 'package:caloin/features/settings/data/settings_provider.dart';
import 'package:caloin/features/settings/domain/settings_enums.dart';
import 'package:caloin/features/settings/presentation/settings_screen.dart';
import 'package:caloin/l10n/app_localizations.dart';

void main() {
  testWidgets('SettingsScreen: displays profile, switches units, theme, and opens delete dialog', (tester) async {
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

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const testProfile = UserProfile(
      gender: Gender.male,
      age: 25,
      heightCm: 175.0,
      weightKg: 70.0,
      activityLevel: ActivityLevel.moderate,
      goal: Goal.maintain,
      dailyGoalKcal: 2560,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
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
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Sections
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Hồ sơ & Mục tiêu'), findsOneWidget);
    expect(find.text('2560 kcal'), findsOneWidget);
    expect(find.text('Nam • 25 tuổi'), findsOneWidget);
    expect(find.text('175 cm • 70.0 kg'), findsOneWidget);

    // Switch Weight Unit to 'lb'
    await tester.tap(find.text('lb'));
    await tester.pumpAndSettle();
    expect(find.text('175 cm • 154.3 lb'), findsOneWidget);

    // Switch Height Unit to 'ft/in'
    await tester.tap(find.text('ft/in'));
    await tester.pumpAndSettle();
    expect(find.text("5'9\" • 154.3 lb"), findsOneWidget);

    // Tap "Xóa toàn bộ dữ liệu" to open confirmation dialog
    final deleteTile = find.text('Xóa toàn bộ dữ liệu');
    expect(deleteTile, findsOneWidget);
    await tester.tap(deleteTile);
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Hành động này sẽ xóa vĩnh viễn toàn bộ nhật ký, món tùy chỉnh và hồ sơ. Bạn không thể hoàn tác.'), findsOneWidget);
    expect(find.text('Xóa và Đặt lại'), findsOneWidget);

    // Dismiss dialog with Hủy
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Xóa và Đặt lại'), findsNothing);
  });
}

class _MockProfileNotifier extends ProfileNotifier {
  _MockProfileNotifier(this._initial);
  final UserProfile _initial;

  @override
  Future<UserProfile?> build() async => _initial;
}
