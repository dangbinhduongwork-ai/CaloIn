import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/vietnamese_utils.dart';
import '../domain/food.dart';
import '../domain/food_repository.dart';

const String _prefSeedVersionKey = 'foods_seed_version';

class FoodRepositoryImpl implements FoodRepository {
  FoodRepositoryImpl({
    required AppDatabase db,
    SharedPreferences? prefs,
  })  : _db = db,
        _prefs = prefs;

  final AppDatabase _db;
  final SharedPreferences? _prefs;

  Food _toEntity(FoodEntry row) {
    return Food(
      id: row.id.toString(),
      nameVi: row.nameVi,
      nameEn: row.nameEn,
      kcalPer100g: row.kcalPer100g,
      proteinPer100g: row.proteinPer100g,
      carbPer100g: row.carbPer100g,
      fatPer100g: row.fatPer100g,
      defaultServingGrams: row.defaultServingGrams,
      servingLabelKey: row.servingLabelKey,
      category: row.category,
      isCustom: row.isCustom,
      isFavorite: row.isFavorite,
      dataQuality: row.dataQuality,
    );
  }

  @override
  Future<List<Food>> search(
    String query, {
    String? category,
    int limit = 50,
  }) async {
    final normalizedQuery = VietnameseUtils.normalize(query);
    final queryWords = normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();

    var selectQuery = _db.select(_db.foods);

    if (category != null && category.isNotEmpty && category != 'all') {
      selectQuery = selectQuery..where((tbl) => tbl.category.equals(category));
    }

    if (queryWords.isNotEmpty) {
      selectQuery = selectQuery
        ..where((tbl) {
          Expression<bool> combined = tbl.searchKey.contains(queryWords.first);
          for (int i = 1; i < queryWords.length; i++) {
            combined = combined & tbl.searchKey.contains(queryWords[i]);
          }
          return combined;
        });
    }

    final rows = await selectQuery.get();

    // Sort/rank results:
    // 1. startsWith full normalized query
    // 2. isFavorite
    // 3. nameVi alphabetically
    final sorted = List<FoodEntry>.from(rows)
      ..sort((a, b) {
        if (normalizedQuery.isNotEmpty) {
          final aStarts = a.searchKey.startsWith(normalizedQuery);
          final bStarts = b.searchKey.startsWith(normalizedQuery);
          if (aStarts && !bStarts) return -1;
          if (!aStarts && bStarts) return 1;
        }

        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;

        return a.nameVi.compareTo(b.nameVi);
      });

    final limited = sorted.take(limit).map(_toEntity).toList();
    return limited;
  }

  @override
  Stream<List<Food>> watchFavorites() {
    final query = _db.select(_db.foods)
      ..where((tbl) => tbl.isFavorite.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.nameVi)]);

    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Stream<List<Food>> watchCustomFoods() {
    final query = _db.select(_db.foods)
      ..where((tbl) => tbl.isCustom.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.nameVi)]);

    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<Food>> getAllFoods() async {
    final rows = await (_db.select(_db.foods)..orderBy([(tbl) => OrderingTerm.asc(tbl.nameVi)])).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Food?> getFoodById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;

    final query = _db.select(_db.foods)..where((tbl) => tbl.id.equals(intId));
    final row = await query.getSingleOrNull();
    return row != null ? _toEntity(row) : null;
  }

  @override
  Future<void> toggleFavorite(String foodId) async {
    final intId = int.tryParse(foodId);
    if (intId == null) return;

    final existing = await (_db.select(_db.foods)..where((tbl) => tbl.id.equals(intId))).getSingleOrNull();
    if (existing == null) return;

    await (_db.update(_db.foods)..where((tbl) => tbl.id.equals(intId))).write(
      FoodsCompanion(isFavorite: Value(!existing.isFavorite)),
    );
  }

  @override
  Future<Food> addCustomFood(Food food) async {
    final searchKey = VietnameseUtils.normalize('${food.nameVi} ${food.nameEn}');
    final companion = FoodsCompanion.insert(
      nameVi: food.nameVi,
      nameEn: food.nameEn.isEmpty ? food.nameVi : food.nameEn,
      searchKey: searchKey,
      kcalPer100g: food.kcalPer100g,
      proteinPer100g: food.proteinPer100g,
      carbPer100g: food.carbPer100g,
      fatPer100g: food.fatPer100g,
      defaultServingGrams: food.defaultServingGrams,
      servingLabelKey: food.servingLabelKey,
      category: food.category,
      isCustom: const Value(true),
      isFavorite: Value(food.isFavorite),
      dataQuality: const Value('custom'),
    );

    final insertedId = await _db.into(_db.foods).insert(companion);
    return food.copyWith(
      id: insertedId.toString(),
      isCustom: true,
      dataQuality: 'custom',
    );
  }

  @override
  Future<void> updateCustomFood(Food food) async {
    final intId = int.tryParse(food.id);
    if (intId == null) throw ArgumentError('Invalid food id: ${food.id}');

    final existing = await (_db.select(_db.foods)..where((tbl) => tbl.id.equals(intId))).getSingleOrNull();
    if (existing == null) throw StateError('Food not found');
    if (!existing.isCustom) throw StateError('Cannot modify seed food');

    final searchKey = VietnameseUtils.normalize('${food.nameVi} ${food.nameEn}');
    await (_db.update(_db.foods)..where((tbl) => tbl.id.equals(intId))).write(
      FoodsCompanion(
        nameVi: Value(food.nameVi),
        nameEn: Value(food.nameEn.isEmpty ? food.nameVi : food.nameEn),
        searchKey: Value(searchKey),
        kcalPer100g: Value(food.kcalPer100g),
        proteinPer100g: Value(food.proteinPer100g),
        carbPer100g: Value(food.carbPer100g),
        fatPer100g: Value(food.fatPer100g),
        defaultServingGrams: Value(food.defaultServingGrams),
        servingLabelKey: Value(food.servingLabelKey),
        category: Value(food.category),
        isFavorite: Value(food.isFavorite),
      ),
    );
  }

  @override
  Future<void> deleteCustomFood(String foodId) async {
    final intId = int.tryParse(foodId);
    if (intId == null) return;

    final existing = await (_db.select(_db.foods)..where((tbl) => tbl.id.equals(intId))).getSingleOrNull();
    if (existing == null) return;
    if (!existing.isCustom) throw StateError('Cannot delete seed food');

    await (_db.delete(_db.foods)..where((tbl) => tbl.id.equals(intId))).go();
  }

  @override
  Future<void> seedFoods(List<Map<String, dynamic>> rawFoods, {required int version}) async {
    await _db.transaction(() async {
      for (final raw in rawFoods) {
        final seedKey = raw['seedKey'] as String;
        final nameVi = raw['nameVi'] as String;
        final nameEn = (raw['nameEn'] as String?) ?? nameVi;
        final searchKey = VietnameseUtils.normalize('$nameVi $nameEn');
        final kcal = (raw['kcalPer100g'] as num).toDouble();
        final protein = (raw['proteinPer100g'] as num).toDouble();
        final carb = (raw['carbPer100g'] as num).toDouble();
        final fat = (raw['fatPer100g'] as num).toDouble();
        final servingGrams = (raw['defaultServingGrams'] as num).toDouble();
        final servingKey = (raw['servingLabelKey'] as String?) ?? 'portion';
        final category = (raw['category'] as String?) ?? 'other';
        final quality = (raw['dataQuality'] as String?) ?? 'estimated';

        final existing = await (_db.select(_db.foods)
              ..where((tbl) => tbl.seedKey.equals(seedKey)))
            .getSingleOrNull();

        if (existing != null) {
          // Upsert: keep isFavorite and id, update nutritional & name fields
          await (_db.update(_db.foods)..where((tbl) => tbl.id.equals(existing.id))).write(
            FoodsCompanion(
              nameVi: Value(nameVi),
              nameEn: Value(nameEn),
              searchKey: Value(searchKey),
              kcalPer100g: Value(kcal),
              proteinPer100g: Value(protein),
              carbPer100g: Value(carb),
              fatPer100g: Value(fat),
              defaultServingGrams: Value(servingGrams),
              servingLabelKey: Value(servingKey),
              category: Value(category),
              dataQuality: Value(quality),
            ),
          );
        } else {
          // Insert fresh seed item
          await _db.into(_db.foods).insert(
                FoodsCompanion.insert(
                  seedKey: Value(seedKey),
                  nameVi: nameVi,
                  nameEn: nameEn,
                  searchKey: searchKey,
                  kcalPer100g: kcal,
                  proteinPer100g: protein,
                  carbPer100g: carb,
                  fatPer100g: fat,
                  defaultServingGrams: servingGrams,
                  servingLabelKey: servingKey,
                  category: category,
                  isCustom: const Value(false),
                  isFavorite: const Value(false),
                  dataQuality: Value(quality),
                ),
              );
        }
      }
    });

    if (_prefs != null) {
      await _prefs.setInt(_prefSeedVersionKey, version);
    }
  }
}
