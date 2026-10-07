import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caloin/main.dart';
import 'package:caloin/core/theme/theme_provider.dart';

void main() {
  testWidgets('CaloInApp smoke test: loads Onboarding screen when no profile exists', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
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

    expect(find.text('CaloIn'), findsWidgets);
  });
}
