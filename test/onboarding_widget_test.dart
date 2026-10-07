import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/core/router/app_router.dart';
import 'package:caloin/core/theme/theme_provider.dart';
import 'package:caloin/features/profile/data/onboarding_draft_provider.dart';
import 'package:caloin/features/profile/data/profile_providers.dart';
import 'package:caloin/features/profile/presentation/onboarding_screen.dart';
import 'package:caloin/features/profile/presentation/onboarding_summary_screen.dart';
import 'package:caloin/features/profile/presentation/widgets/macro_ratio_selector.dart';
import 'package:caloin/l10n/app_localizations.dart';

void main() {
  testWidgets('Onboarding Step 1: Age 17 blocks continue and displays underAge message; Age 25 passes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
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
          home: OnboardingScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final ageField = find.byType(TextFormField);
    expect(ageField, findsOneWidget);

    // Enter age 17
    await tester.enterText(ageField, '17');
    await tester.pumpAndSettle();

    // Verify underAge warning is visible
    expect(find.textContaining('Ứng dụng chỉ dành cho người từ 18 tuổi trở lên'), findsOneWidget);

    // Button should be disabled
    final nextButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(nextButton.onPressed, isNull);

    // Now enter age 25
    await tester.enterText(ageField, '25');
    await tester.pumpAndSettle();

    expect(find.textContaining('Ứng dụng chỉ dành cho người từ 18 tuổi trở lên'), findsNothing);
    final activeNextButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(activeNextButton.onPressed, isNotNull);
  });

  testWidgets('Onboarding Step 2: Switching units converts values accurately', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
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
          home: OnboardingScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Advance to step 2
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Chiều cao & Cân nặng'), findsOneWidget);

    // Initial weight is 65.0 kg
    expect(find.text('65.0'), findsOneWidget);

    // Toggle weight unit to lb
    final toggleWeightBtn = find.text('kg');
    expect(toggleWeightBtn, findsOneWidget);
    await tester.tap(toggleWeightBtn);
    await tester.pumpAndSettle();

    // 65.0 kg * 2.20462 = 143.3 lb
    expect(find.text('143.3'), findsOneWidget);
    expect(find.text('lb'), findsWidgets);

    // Toggle back to kg
    await tester.tap(find.text('lb').first);
    await tester.pumpAndSettle();
    expect(find.text('65.0'), findsOneWidget);
  });

  testWidgets('MacroRatioSelector: Custom preset with sum != 100 shows error and disables start', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
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
          home: OnboardingSummaryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap 'Tùy chỉnh' preset chip
    final customChip = find.text('Tùy chỉnh');
    expect(customChip, findsOneWidget);
    await tester.tap(customChip);
    await tester.pumpAndSettle();

    // Change protein to 40 (sum becomes 40 + 50 + 30 = 120%)
    final proteinField = find.byType(TextFormField).first;
    await tester.enterText(proteinField, '40');
    await tester.pumpAndSettle();

    expect(find.textContaining('Tổng tỉ lệ phải bằng 100%'), findsOneWidget);

    // Get Started button should be disabled
    final getStartedButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(getStartedButton.onPressed, isNull);
  });

  testWidgets('Router: Redirects to /onboarding when no profile exists', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              locale: const Locale('vi'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Automatically redirected to Onboarding screen!
    expect(find.text('Thông tin cơ bản'), findsOneWidget);
  });
}
