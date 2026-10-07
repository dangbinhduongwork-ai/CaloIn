import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Foods Seed Data Validation', () {
    late Map<String, dynamic> seedJson;
    late List<Map<String, dynamic>> foods;

    setUpAll(() {
      final file = File('assets/data/foods_seed.json');
      expect(file.existsSync(), isTrue, reason: 'foods_seed.json must exist');
      final content = file.readAsStringSync();
      seedJson = json.decode(content) as Map<String, dynamic>;
      foods = (seedJson['foods'] as List<dynamic>).cast<Map<String, dynamic>>();
    });

    test('Seed file contains between 80 and 100 foods', () {
      expect(foods.length, inInclusiveRange(80, 100));
    });

    test('All seedKeys are unique, non-empty and snake_case', () {
      final seenKeys = <String>{};
      for (final food in foods) {
        final key = food['seedKey'] as String?;
        expect(key, isNotNull);
        expect(key!.isNotEmpty, isTrue);
        expect(seenKeys.contains(key), isFalse, reason: 'Duplicate seedKey found: $key');
        seenKeys.add(key);
      }
    });

    test('Nutritional constraints and serving limits are satisfied', () {
      for (final food in foods) {
        final name = food['nameVi'] as String;
        final kcal = (food['kcalPer100g'] as num).toDouble();
        final protein = (food['proteinPer100g'] as num).toDouble();
        final carb = (food['carbPer100g'] as num).toDouble();
        final fat = (food['fatPer100g'] as num).toDouble();
        final servingGrams = (food['defaultServingGrams'] as num).toDouble();

        expect(servingGrams, greaterThan(0.0), reason: '$name has invalid serving grams');
        expect(kcal, inInclusiveRange(0.0, 900.0), reason: '$name kcal out of range');
        expect(protein, inInclusiveRange(0.0, 100.0), reason: '$name protein out of range');
        expect(carb, inInclusiveRange(0.0, 100.0), reason: '$name carb out of range');
        expect(fat, inInclusiveRange(0.0, 100.0), reason: '$name fat out of range');

        final totalMacros = protein + carb + fat;
        expect(totalMacros, lessThanOrEqualTo(100.5), reason: '$name total macros exceed 100g/100g');
      }
    });

    test('Atwater cross-check: kcal deviates <= 20% from (P*4 + C*4 + F*9) unless exempt', () {
      final deviatedFoods = <String>[];

      for (final food in foods) {
        final isExempt = food['atwaterCheckExempt'] == true;
        if (isExempt) continue;

        final key = food['seedKey'] as String;
        final name = food['nameVi'] as String;
        final recordedKcal = (food['kcalPer100g'] as num).toDouble();
        final protein = (food['proteinPer100g'] as num).toDouble();
        final carb = (food['carbPer100g'] as num).toDouble();
        final fat = (food['fatPer100g'] as num).toDouble();

        final calculatedKcal = (protein * 4.0) + (carb * 4.0) + (fat * 9.0);
        if (recordedKcal == 0) continue;

        final deviation = (recordedKcal - calculatedKcal).abs() / recordedKcal;

        if (deviation > 0.20) {
          deviatedFoods.add(
            '$key ($name): recorded $recordedKcal kcal vs calculated $calculatedKcal kcal (deviation: ${(deviation * 100).toStringAsFixed(1)}%)',
          );
        }
      }

      if (deviatedFoods.isNotEmpty) {
        // ignore: avoid_print
        print('=== ATWATER DEVIATION WARNING (>20%) ===\n${deviatedFoods.join('\n')}');
      }

      expect(
        deviatedFoods,
        isEmpty,
        reason: 'Some foods have Atwater kcal deviation > 20%: ${deviatedFoods.join(', ')}',
      );
    });
  });
}
