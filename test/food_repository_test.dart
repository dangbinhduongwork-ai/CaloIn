import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caloin/core/database/app_database.dart';
import 'package:caloin/features/foods/data/food_repository_impl.dart';
import 'package:caloin/features/foods/domain/food.dart';

void main() {
  group('FoodRepositoryImpl In-Memory Database Tests', () {
    late AppDatabase db;
    late FoodRepositoryImpl repository;

    final mockSeedBatch = [
      {
        'seedKey': 'pho_bo',
        'nameVi': 'Phở bò tái',
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
      {
        'seedKey': 'dau_hu_trang',
        'nameVi': 'Đậu hũ trắng',
        'nameEn': 'Raw Tofu',
        'kcalPer100g': 76.0,
        'proteinPer100g': 8.0,
        'carbPer100g': 1.9,
        'fatPer100g': 4.5,
        'defaultServingGrams': 150.0,
        'servingLabelKey': 'piece',
        'category': 'egg_dairy',
        'dataQuality': 'estimated',
      },
      {
        'seedKey': 'com_tam',
        'nameVi': 'Cơm tấm sườn',
        'nameEn': 'Broken Rice',
        'kcalPer100g': 175.0,
        'proteinPer100g': 7.5,
        'carbPer100g': 23.5,
        'fatPer100g': 5.5,
        'defaultServingGrams': 350.0,
        'servingLabelKey': 'plate',
        'category': 'carb',
        'dataQuality': 'estimated',
      },
    ];

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      db = AppDatabase(NativeDatabase.memory());
      repository = FoodRepositoryImpl(db: db, prefs: prefs);
    });

    tearDown(() async {
      await db.close();
    });

    test('Imports seed foods and does not duplicate on re-import', () async {
      await repository.seedFoods(mockSeedBatch, version: 1);
      final initialFoods = await repository.getAllFoods();
      expect(initialFoods.length, 3);

      // Re-importing same or upgraded version should not create duplicates
      await repository.seedFoods(mockSeedBatch, version: 2);
      final afterReimport = await repository.getAllFoods();
      expect(afterReimport.length, 3);
    });

    test('Preserves isFavorite state when upgrading seedVersion', () async {
      await repository.seedFoods(mockSeedBatch, version: 1);

      // Find pho_bo and mark as favorite
      final foods = await repository.getAllFoods();
      final phoBo = foods.firstWhere((f) => f.nameVi.contains('Phở'));
      await repository.toggleFavorite(phoBo.id);

      final favoritedPho = await repository.getFoodById(phoBo.id);
      expect(favoritedPho?.isFavorite, isTrue);

      // Upgrade seed data with updated name
      final updatedBatch = [
        {
          ...mockSeedBatch[0],
          'nameVi': 'Phở bò tái nạm đặc biệt',
        },
        mockSeedBatch[1],
        mockSeedBatch[2],
      ];

      await repository.seedFoods(updatedBatch, version: 2);

      final reloadedPho = await repository.getFoodById(phoBo.id);
      expect(reloadedPho?.nameVi, 'Phở bò tái nạm đặc biệt');
      // Must KEEP isFavorite: true
      expect(reloadedPho?.isFavorite, isTrue);
    });

    test('Searches without diacritics ("pho bo", "dau")', () async {
      await repository.seedFoods(mockSeedBatch, version: 1);

      // "pho bo" should match "Phở bò tái"
      final phoResults = await repository.search('pho bo');
      expect(phoResults.length, 1);
      expect(phoResults.first.nameVi, contains('Phở bò'));

      // "dau" should match "Đậu hũ trắng"
      final dauResults = await repository.search('dau');
      expect(dauResults.length, 1);
      expect(dauResults.first.nameVi, contains('Đậu hũ'));
    });

    test('Adds, updates, and deletes custom foods correctly', () async {
      const custom = Food(
        id: '',
        nameVi: 'Salad cá ngừ tự làm',
        nameEn: 'Homemade Tuna Salad',
        kcalPer100g: 110.0,
        proteinPer100g: 12.0,
        carbPer100g: 5.0,
        fatPer100g: 4.5,
        defaultServingGrams: 200.0,
        servingLabelKey: 'bowl',
        category: 'fish_seafood',
        isCustom: true,
      );

      final inserted = await repository.addCustomFood(custom);
      expect(inserted.id.isNotEmpty, isTrue);
      expect(inserted.isCustom, isTrue);

      // Update custom food
      final updated = inserted.copyWith(kcalPer100g: 125.0);
      await repository.updateCustomFood(updated);
      final fetched = await repository.getFoodById(inserted.id);
      expect(fetched?.kcalPer100g, 125.0);

      // Delete custom food
      await repository.deleteCustomFood(inserted.id);
      final afterDelete = await repository.getFoodById(inserted.id);
      expect(afterDelete, isNull);
    });

    test('Cannot modify or delete seed foods', () async {
      await repository.seedFoods(mockSeedBatch, version: 1);
      final foods = await repository.getAllFoods();
      final seedFood = foods.first;

      // Updating seed food must fail
      expect(
        () async => repository.updateCustomFood(seedFood),
        throwsA(isA<StateError>()),
      );

      // Deleting seed food must fail
      expect(
        () async => repository.deleteCustomFood(seedFood.id),
        throwsA(isA<StateError>()),
      );
    });
  });
}
