import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get seedKey => text().nullable().unique()();
  TextColumn get nameVi => text()();
  TextColumn get nameEn => text()();
  TextColumn get searchKey => text()();
  RealColumn get kcalPer100g => real()();
  RealColumn get proteinPer100g => real()();
  RealColumn get carbPer100g => real()();
  RealColumn get fatPer100g => real()();
  RealColumn get defaultServingGrams => real()();
  TextColumn get servingLabelKey => text()();
  TextColumn get category => text()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get dataQuality => text().withDefault(const Constant('estimated'))();
}

@TableIndex(name: 'idx_food_logs_logged_at', columns: {#loggedAt})
class FoodLogs extends Table {
  TextColumn get id => text()();
  TextColumn get foodId => text().nullable()();
  TextColumn get foodNameSnapshot => text()();
  TextColumn get mealType => text()();
  RealColumn get grams => real().nullable()();
  RealColumn get kcal => real()();
  RealColumn get protein => real()();
  RealColumn get carb => real()();
  RealColumn get fat => real()();
  BoolColumn get isQuickAdd => boolean().withDefault(const Constant(false))();
  DateTimeColumn get loggedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Foods, FoodLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'caloin.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
