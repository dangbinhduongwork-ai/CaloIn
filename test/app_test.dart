import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caloin/main.dart';
import 'package:caloin/core/theme/theme_provider.dart';

void main() {
  testWidgets('CaloInApp loads and displays dashboard initial screen', (WidgetTester tester) async {
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

    expect(find.text('CaloIn'), findsOneWidget);
    expect(find.text('Hôm nay'), findsWidgets);
    expect(find.text('Món ăn'), findsOneWidget);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
  });
}
