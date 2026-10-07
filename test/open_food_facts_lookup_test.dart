import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:caloin/features/foods/data/open_food_facts_lookup_service_impl.dart';
import 'package:caloin/features/foods/domain/barcode_lookup_result.dart';
import 'package:caloin/features/foods/domain/barcode_product.dart';

void main() {
  group('OpenFoodFactsLookupServiceImpl Tests', () {
    test('returns BarcodeLookupNotFound for empty barcode string', () async {
      final service = OpenFoodFactsLookupServiceImpl();
      final result = await service.lookup('   ');

      expect(result, isA<BarcodeLookupNotFound>());
      expect((result as BarcodeLookupNotFound).barcode, isEmpty);
    });

    test('successful lookup parses product details, nutriments and verifies User-Agent header', () async {
      String? recordedUserAgent;

      final mockClient = MockClient((request) async {
        recordedUserAgent = request.headers['User-Agent'];
        expect(request.url.toString(), contains('8934567890123.json'));
        expect(request.url.queryParameters['fields'], contains('nutriments'));

        final responseJson = {
          'status': 1,
          'product': {
            'product_name': 'Sữa tươi tiệt trùng',
            'product_name_vi': 'Sữa tươi tiệt trùng có đường',
            'brands': 'Vinamilk',
            'serving_quantity': 180,
            'serving_size': '180 ml',
            'nutriments': {
              'energy-kcal_100g': 73.2,
              'proteins_100g': 3.0,
              'carbohydrates_100g': 8.5,
              'fat_100g': 3.2,
            },
            'image_front_url': 'https://images.openfoodfacts.org/front.jpg',
          },
        };

        return http.Response(jsonEncode(responseJson), 200, headers: {
          'content-type': 'application/json',
        });
      });

      final service = OpenFoodFactsLookupServiceImpl(client: mockClient);
      final result = await service.lookup('8934567890123');

      expect(result, isA<BarcodeLookupSuccess>());
      final product = (result as BarcodeLookupSuccess).product;

      expect(product.barcode, '8934567890123');
      expect(product.name, 'Sữa tươi tiệt trùng có đường');
      expect(product.brand, 'Vinamilk');
      expect(product.kcalPer100g, 73.2);
      expect(product.proteinPer100g, 3.0);
      expect(product.carbPer100g, 8.5);
      expect(product.fatPer100g, 3.2);
      expect(product.defaultServingGrams, 180.0);
      expect(product.hasCompleteNutrition, isTrue);

      expect(recordedUserAgent, contains('CaloIn - Flutter - Version 1.0.0'));
    });

    test('converts energy from kJ when kcal is missing', () async {
      final mockClient = MockClient((request) async {
        final responseJson = {
          'status': 1,
          'product': {
            'product_name': 'Bánh quy bơ',
            'nutriments': {
              'energy_100g': 2092.0, // 2092 kJ / 4.184 = 500 kcal
              'proteins_100g': 6.0,
              'carbohydrates_100g': 65.0,
              'fat_100g': 24.0,
            },
          },
        };

        return http.Response(jsonEncode(responseJson), 200);
      });

      final service = OpenFoodFactsLookupServiceImpl(client: mockClient);
      final result = await service.lookup('12345678');

      expect(result, isA<BarcodeLookupSuccess>());
      final product = (result as BarcodeLookupSuccess).product;
      expect(product.kcalPer100g, closeTo(500.0, 0.5));
    });

    test('extracts serving size in grams from serving_size string', () async {
      final mockClient = MockClient((request) async {
        final responseJson = {
          'status': 1,
          'product': {
            'product_name': 'Mì ly Handy Hảo Hảo',
            'serving_size': '67 g',
            'nutriments': {
              'energy-kcal_100g': 450.0,
              'proteins_100g': 9.0,
              'carbohydrates_100g': 60.0,
              'fat_100g': 18.0,
            },
          },
        };

        return http.Response(jsonEncode(responseJson), 200);
      });

      final service = OpenFoodFactsLookupServiceImpl(client: mockClient);
      final result = await service.lookup('8934563141122');

      expect(result, isA<BarcodeLookupSuccess>());
      final product = (result as BarcodeLookupSuccess).product;
      expect(product.defaultServingGrams, 67.0);
      expect(product.servingLabel, 'cup');
    });

    test('returns BarcodeLookupNotFound on 404 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"status":0,"status_verbose":"product not found"}', 404);
      });

      final service = OpenFoodFactsLookupServiceImpl(client: mockClient);
      final result = await service.lookup('9999999999999');

      expect(result, isA<BarcodeLookupNotFound>());
      expect((result as BarcodeLookupNotFound).barcode, '9999999999999');
    });

    test('returns BarcodeLookupNotFound when status is 0 or product is null', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'status': 0, 'product': null}), 200);
      });

      final service = OpenFoodFactsLookupServiceImpl(client: mockClient);
      final result = await service.lookup('00000000');

      expect(result, isA<BarcodeLookupNotFound>());
    });

    test('returns BarcodeLookupIncompleteNutrition when all nutritional fields are 0', () async {
      final mockClient = MockClient((request) async {
        final responseJson = {
          'status': 1,
          'product': {
            'product_name': 'Nước lọc tinh khiết không nhãn dinh dưỡng',
            'nutriments': <String, dynamic>{},
          },
        };

        return http.Response(jsonEncode(responseJson), 200);
      });

      final service = OpenFoodFactsLookupServiceImpl(client: mockClient);
      final result = await service.lookup('11112222');

      expect(result, isA<BarcodeLookupIncompleteNutrition>());
      final product = (result as BarcodeLookupIncompleteNutrition).product;
      expect(product.hasCompleteNutrition, isFalse);
      expect(product.kcalPer100g, 0.0);
    });

    test('returns BarcodeLookupTimeout when request times out', () async {
      final mockClient = MockClient((request) async {
        throw TimeoutException('Connection timeout');
      });

      final service = OpenFoodFactsLookupServiceImpl(client: mockClient);
      final result = await service.lookup('123456');

      expect(result, isA<BarcodeLookupTimeout>());
    });

    test('returns BarcodeLookupNetworkError on SocketException or 500 error', () async {
      final socketClient = MockClient((request) async {
        throw const SocketException('No address associated with hostname');
      });

      final service1 = OpenFoodFactsLookupServiceImpl(client: socketClient);
      final result1 = await service1.lookup('123456');
      expect(result1, isA<BarcodeLookupNetworkError>());

      final serverErrorClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service2 = OpenFoodFactsLookupServiceImpl(client: serverErrorClient);
      final result2 = await service2.lookup('123456');
      expect(result2, isA<BarcodeLookupNetworkError>());
    });

    test('BarcodeProduct.toCustomFood converts accurately to Food domain entity', () {
      const product = BarcodeProduct(
        barcode: '8934567890123',
        name: 'Sữa Milo hộp',
        brand: 'Nestle',
        kcalPer100g: 70.0,
        proteinPer100g: 2.2,
        carbPer100g: 10.5,
        fatPer100g: 2.1,
        defaultServingGrams: 180.0,
        servingLabel: 'can',
        imageUrl: 'https://img.jpg',
        hasCompleteNutrition: true,
      );

      final food = product.toCustomFood();

      expect(food.isCustom, isTrue);
      expect(food.dataQuality, 'community');
      expect(food.nameVi, 'Sữa Milo hộp (Nestle)');
      expect(food.kcalPer100g, 70.0);
      expect(food.proteinPer100g, 2.2);
      expect(food.carbPer100g, 10.5);
      expect(food.fatPer100g, 2.1);
      expect(food.defaultServingGrams, 180.0);
      expect(food.servingUnitLabel, 'can');
    });
  });
}
