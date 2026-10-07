// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class FoodEntry extends DataClass implements Insertable<FoodEntry> {
  final int id;
  final String? seedKey;
  final String nameVi;
  final String nameEn;
  final String searchKey;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbPer100g;
  final double fatPer100g;
  final double defaultServingGrams;
  final String servingLabelKey;
  final String category;
  final bool isCustom;
  final bool isFavorite;
  final String dataQuality;

  const FoodEntry({
    required this.id,
    this.seedKey,
    required this.nameVi,
    required this.nameEn,
    required this.searchKey,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbPer100g,
    required this.fatPer100g,
    required this.defaultServingGrams,
    required this.servingLabelKey,
    required this.category,
    required this.isCustom,
    required this.isFavorite,
    required this.dataQuality,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || seedKey != null) {
      map['seed_key'] = Variable<String>(seedKey);
    }
    map['name_vi'] = Variable<String>(nameVi);
    map['name_en'] = Variable<String>(nameEn);
    map['search_key'] = Variable<String>(searchKey);
    map['kcal_per100g'] = Variable<double>(kcalPer100g);
    map['protein_per100g'] = Variable<double>(proteinPer100g);
    map['carb_per100g'] = Variable<double>(carbPer100g);
    map['fat_per100g'] = Variable<double>(fatPer100g);
    map['default_serving_grams'] = Variable<double>(defaultServingGrams);
    map['serving_label_key'] = Variable<String>(servingLabelKey);
    map['category'] = Variable<String>(category);
    map['is_custom'] = Variable<bool>(isCustom);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['data_quality'] = Variable<String>(dataQuality);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      seedKey: seedKey == null && nullToAbsent ? const Value.absent() : Value(seedKey),
      nameVi: Value(nameVi),
      nameEn: Value(nameEn),
      searchKey: Value(searchKey),
      kcalPer100g: Value(kcalPer100g),
      proteinPer100g: Value(proteinPer100g),
      carbPer100g: Value(carbPer100g),
      fatPer100g: Value(fatPer100g),
      defaultServingGrams: Value(defaultServingGrams),
      servingLabelKey: Value(servingLabelKey),
      category: Value(category),
      isCustom: Value(isCustom),
      isFavorite: Value(isFavorite),
      dataQuality: Value(dataQuality),
    );
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodEntry(
      id: serializer.fromJson<int>(json['id']),
      seedKey: serializer.fromJson<String?>(json['seedKey']),
      nameVi: serializer.fromJson<String>(json['nameVi']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      kcalPer100g: serializer.fromJson<double>(json['kcalPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      carbPer100g: serializer.fromJson<double>(json['carbPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      defaultServingGrams: serializer.fromJson<double>(json['defaultServingGrams']),
      servingLabelKey: serializer.fromJson<String>(json['servingLabelKey']),
      category: serializer.fromJson<String>(json['category']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      dataQuality: serializer.fromJson<String>(json['dataQuality']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seedKey': serializer.toJson<String?>(seedKey),
      'nameVi': serializer.toJson<String>(nameVi),
      'nameEn': serializer.toJson<String>(nameEn),
      'searchKey': serializer.toJson<String>(searchKey),
      'kcalPer100g': serializer.toJson<double>(kcalPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'carbPer100g': serializer.toJson<double>(carbPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'defaultServingGrams': serializer.toJson<double>(defaultServingGrams),
      'servingLabelKey': serializer.toJson<String>(servingLabelKey),
      'category': serializer.toJson<String>(category),
      'isCustom': serializer.toJson<bool>(isCustom),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'dataQuality': serializer.toJson<String>(dataQuality),
    };
  }

  FoodEntry copyWith({
    int? id,
    Value<String?> seedKey = const Value.absent(),
    String? nameVi,
    String? nameEn,
    String? searchKey,
    double? kcalPer100g,
    double? proteinPer100g,
    double? carbPer100g,
    double? fatPer100g,
    double? defaultServingGrams,
    String? servingLabelKey,
    String? category,
    bool? isCustom,
    bool? isFavorite,
    String? dataQuality,
  }) =>
      FoodEntry(
        id: id ?? this.id,
        seedKey: seedKey.present ? seedKey.value : this.seedKey,
        nameVi: nameVi ?? this.nameVi,
        nameEn: nameEn ?? this.nameEn,
        searchKey: searchKey ?? this.searchKey,
        kcalPer100g: kcalPer100g ?? this.kcalPer100g,
        proteinPer100g: proteinPer100g ?? this.proteinPer100g,
        carbPer100g: carbPer100g ?? this.carbPer100g,
        fatPer100g: fatPer100g ?? this.fatPer100g,
        defaultServingGrams: defaultServingGrams ?? this.defaultServingGrams,
        servingLabelKey: servingLabelKey ?? this.servingLabelKey,
        category: category ?? this.category,
        isCustom: isCustom ?? this.isCustom,
        isFavorite: isFavorite ?? this.isFavorite,
        dataQuality: dataQuality ?? this.dataQuality,
      );

  @override
  String toString() {
    return (StringBuffer('FoodEntry(')
          ..write('id: $id, ')
          ..write('seedKey: $seedKey, ')
          ..write('nameVi: $nameVi, ')
          ..write('nameEn: $nameEn, ')
          ..write('searchKey: $searchKey, ')
          ..write('kcalPer100g: $kcalPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbPer100g: $carbPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('defaultServingGrams: $defaultServingGrams, ')
          ..write('servingLabelKey: $servingLabelKey, ')
          ..write('category: $category, ')
          ..write('isCustom: $isCustom, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('dataQuality: $dataQuality')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
        id,
        seedKey,
        nameVi,
        nameEn,
        searchKey,
        kcalPer100g,
        proteinPer100g,
        carbPer100g,
        fatPer100g,
        defaultServingGrams,
        servingLabelKey,
        category,
        isCustom,
        isFavorite,
        dataQuality,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodEntry &&
          other.id == id &&
          other.seedKey == seedKey &&
          other.nameVi == nameVi &&
          other.nameEn == nameEn &&
          other.searchKey == searchKey &&
          other.kcalPer100g == kcalPer100g &&
          other.proteinPer100g == proteinPer100g &&
          other.carbPer100g == carbPer100g &&
          other.fatPer100g == fatPer100g &&
          other.defaultServingGrams == defaultServingGrams &&
          other.servingLabelKey == servingLabelKey &&
          other.category == category &&
          other.isCustom == isCustom &&
          other.isFavorite == isFavorite &&
          other.dataQuality == dataQuality);
}

class FoodsCompanion extends UpdateCompanion<FoodEntry> {
  final Value<int> id;
  final Value<String?> seedKey;
  final Value<String> nameVi;
  final Value<String> nameEn;
  final Value<String> searchKey;
  final Value<double> kcalPer100g;
  final Value<double> proteinPer100g;
  final Value<double> carbPer100g;
  final Value<double> fatPer100g;
  final Value<double> defaultServingGrams;
  final Value<String> servingLabelKey;
  final Value<String> category;
  final Value<bool> isCustom;
  final Value<bool> isFavorite;
  final Value<String> dataQuality;

  const FoodsCompanion({
    this.id = const Value.absent(),
    this.seedKey = const Value.absent(),
    this.nameVi = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.kcalPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.carbPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.defaultServingGrams = const Value.absent(),
    this.servingLabelKey = const Value.absent(),
    this.category = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.dataQuality = const Value.absent(),
  });

  FoodsCompanion.insert({
    this.id = const Value.absent(),
    this.seedKey = const Value.absent(),
    required String nameVi,
    required String nameEn,
    required String searchKey,
    required double kcalPer100g,
    required double proteinPer100g,
    required double carbPer100g,
    required double fatPer100g,
    required double defaultServingGrams,
    required String servingLabelKey,
    required String category,
    this.isCustom = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.dataQuality = const Value.absent(),
  })  : nameVi = Value(nameVi),
        nameEn = Value(nameEn),
        searchKey = Value(searchKey),
        kcalPer100g = Value(kcalPer100g),
        proteinPer100g = Value(proteinPer100g),
        carbPer100g = Value(carbPer100g),
        fatPer100g = Value(fatPer100g),
        defaultServingGrams = Value(defaultServingGrams),
        servingLabelKey = Value(servingLabelKey),
        category = Value(category);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seedKey.present) {
      map['seed_key'] = Variable<String>(seedKey.value);
    }
    if (nameVi.present) {
      map['name_vi'] = Variable<String>(nameVi.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (kcalPer100g.present) {
      map['kcal_per100g'] = Variable<double>(kcalPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per100g'] = Variable<double>(proteinPer100g.value);
    }
    if (carbPer100g.present) {
      map['carb_per100g'] = Variable<double>(carbPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per100g'] = Variable<double>(fatPer100g.value);
    }
    if (defaultServingGrams.present) {
      map['default_serving_grams'] = Variable<double>(defaultServingGrams.value);
    }
    if (servingLabelKey.present) {
      map['serving_label_key'] = Variable<String>(servingLabelKey.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (dataQuality.present) {
      map['data_quality'] = Variable<String>(dataQuality.value);
    }
    return map;
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, FoodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));

  static const VerificationMeta _seedKeyMeta = const VerificationMeta('seedKey');
  @override
  late final GeneratedColumn<String> seedKey = GeneratedColumn<String>(
      'seed_key', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));

  static const VerificationMeta _nameViMeta = const VerificationMeta('nameVi');
  @override
  late final GeneratedColumn<String> nameVi = GeneratedColumn<String>(
      'name_vi', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  static const VerificationMeta _searchKeyMeta = const VerificationMeta('searchKey');
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
      'search_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  static const VerificationMeta _kcalPer100gMeta = const VerificationMeta('kcalPer100g');
  @override
  late final GeneratedColumn<double> kcalPer100g = GeneratedColumn<double>(
      'kcal_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _proteinPer100gMeta = const VerificationMeta('proteinPer100g');
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
      'protein_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _carbPer100gMeta = const VerificationMeta('carbPer100g');
  @override
  late final GeneratedColumn<double> carbPer100g = GeneratedColumn<double>(
      'carb_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _fatPer100gMeta = const VerificationMeta('fatPer100g');
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
      'fat_per100g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _defaultServingGramsMeta = const VerificationMeta('defaultServingGrams');
  @override
  late final GeneratedColumn<double> defaultServingGrams = GeneratedColumn<double>(
      'default_serving_grams', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _servingLabelKeyMeta = const VerificationMeta('servingLabelKey');
  @override
  late final GeneratedColumn<String> servingLabelKey = GeneratedColumn<String>(
      'serving_label_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  static const VerificationMeta _isCustomMeta = const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK (is_custom IN (0, 1))'),
      defaultValue: const Constant(false));

  static const VerificationMeta _isFavoriteMeta = const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK (is_favorite IN (0, 1))'),
      defaultValue: const Constant(false));

  static const VerificationMeta _dataQualityMeta = const VerificationMeta('dataQuality');
  @override
  late final GeneratedColumn<String> dataQuality = GeneratedColumn<String>(
      'data_quality', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('estimated'));

  @override
  List<GeneratedColumn> get $columns => [
        id,
        seedKey,
        nameVi,
        nameEn,
        searchKey,
        kcalPer100g,
        proteinPer100g,
        carbPer100g,
        fatPer100g,
        defaultServingGrams,
        servingLabelKey,
        category,
        isCustom,
        isFavorite,
        dataQuality,
      ];

  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';

  @override
  VerificationContext validateIntegrity(Insertable<FoodEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('seed_key')) {
      context.handle(_seedKeyMeta, seedKey.isAcceptableOrUnknown(data['seed_key']!, _seedKeyMeta));
    }
    if (data.containsKey('name_vi')) {
      context.handle(_nameViMeta, nameVi.isAcceptableOrUnknown(data['name_vi']!, _nameViMeta));
    } else if (isInserting) {
      context.missing(_nameViMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta, nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(_searchKeyMeta, searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta));
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('kcal_per100g')) {
      context.handle(_kcalPer100gMeta, kcalPer100g.isAcceptableOrUnknown(data['kcal_per100g']!, _kcalPer100gMeta));
    } else if (isInserting) {
      context.missing(_kcalPer100gMeta);
    }
    if (data.containsKey('protein_per100g')) {
      context.handle(_proteinPer100gMeta, proteinPer100g.isAcceptableOrUnknown(data['protein_per100g']!, _proteinPer100gMeta));
    } else if (isInserting) {
      context.missing(_proteinPer100gMeta);
    }
    if (data.containsKey('carb_per100g')) {
      context.handle(_carbPer100gMeta, carbPer100g.isAcceptableOrUnknown(data['carb_per100g']!, _carbPer100gMeta));
    } else if (isInserting) {
      context.missing(_carbPer100gMeta);
    }
    if (data.containsKey('fat_per100g')) {
      context.handle(_fatPer100gMeta, fatPer100g.isAcceptableOrUnknown(data['fat_per100g']!, _fatPer100gMeta));
    } else if (isInserting) {
      context.missing(_fatPer100gMeta);
    }
    if (data.containsKey('default_serving_grams')) {
      context.handle(_defaultServingGramsMeta, defaultServingGrams.isAcceptableOrUnknown(data['default_serving_grams']!, _defaultServingGramsMeta));
    } else if (isInserting) {
      context.missing(_defaultServingGramsMeta);
    }
    if (data.containsKey('serving_label_key')) {
      context.handle(_servingLabelKeyMeta, servingLabelKey.isAcceptableOrUnknown(data['serving_label_key']!, _servingLabelKeyMeta));
    } else if (isInserting) {
      context.missing(_servingLabelKeyMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta, isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(_isFavoriteMeta, isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('data_quality')) {
      context.handle(_dataQualityMeta, dataQuality.isAcceptableOrUnknown(data['data_quality']!, _dataQualityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seedKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}seed_key']),
      nameVi: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name_vi'])!,
      nameEn: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      searchKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}search_key'])!,
      kcalPer100g: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}kcal_per100g'])!,
      proteinPer100g: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}protein_per100g'])!,
      carbPer100g: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}carb_per100g'])!,
      fatPer100g: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}fat_per100g'])!,
      defaultServingGrams: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}default_serving_grams'])!,
      servingLabelKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}serving_label_key'])!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      isCustom: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      isFavorite: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      dataQuality: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data_quality'])!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class FoodLogEntryData extends DataClass implements Insertable<FoodLogEntryData> {
  final String id;
  final String? foodId;
  final String foodNameSnapshot;
  final String mealType;
  final double? grams;
  final double kcal;
  final double protein;
  final double carb;
  final double fat;
  final bool isQuickAdd;
  final DateTime loggedAt;

  const FoodLogEntryData({
    required this.id,
    this.foodId,
    required this.foodNameSnapshot,
    required this.mealType,
    this.grams,
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
    required this.isQuickAdd,
    required this.loggedAt,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<String>(foodId);
    }
    map['food_name_snapshot'] = Variable<String>(foodNameSnapshot);
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || grams != null) {
      map['grams'] = Variable<double>(grams);
    }
    map['kcal'] = Variable<double>(kcal);
    map['protein'] = Variable<double>(protein);
    map['carb'] = Variable<double>(carb);
    map['fat'] = Variable<double>(fat);
    map['is_quick_add'] = Variable<bool>(isQuickAdd);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    return map;
  }

  FoodLogsCompanion toCompanion(bool nullToAbsent) {
    return FoodLogsCompanion(
      id: Value(id),
      foodId: foodId == null && nullToAbsent ? const Value.absent() : Value(foodId),
      foodNameSnapshot: Value(foodNameSnapshot),
      mealType: Value(mealType),
      grams: grams == null && nullToAbsent ? const Value.absent() : Value(grams),
      kcal: Value(kcal),
      protein: Value(protein),
      carb: Value(carb),
      fat: Value(fat),
      isQuickAdd: Value(isQuickAdd),
      loggedAt: Value(loggedAt),
    );
  }

  factory FoodLogEntryData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLogEntryData(
      id: serializer.fromJson<String>(json['id']),
      foodId: serializer.fromJson<String?>(json['foodId']),
      foodNameSnapshot: serializer.fromJson<String>(json['foodNameSnapshot']),
      mealType: serializer.fromJson<String>(json['mealType']),
      grams: serializer.fromJson<double?>(json['grams']),
      kcal: serializer.fromJson<double>(json['kcal']),
      protein: serializer.fromJson<double>(json['protein']),
      carb: serializer.fromJson<double>(json['carb']),
      fat: serializer.fromJson<double>(json['fat']),
      isQuickAdd: serializer.fromJson<bool>(json['isQuickAdd']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'foodId': serializer.toJson<String?>(foodId),
      'foodNameSnapshot': serializer.toJson<String>(foodNameSnapshot),
      'mealType': serializer.toJson<String>(mealType),
      'grams': serializer.toJson<double?>(grams),
      'kcal': serializer.toJson<double>(kcal),
      'protein': serializer.toJson<double>(protein),
      'carb': serializer.toJson<double>(carb),
      'fat': serializer.toJson<double>(fat),
      'isQuickAdd': serializer.toJson<bool>(isQuickAdd),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
    };
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogEntryData(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('foodNameSnapshot: $foodNameSnapshot, ')
          ..write('mealType: $mealType, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carb: $carb, ')
          ..write('fat: $fat, ')
          ..write('isQuickAdd: $isQuickAdd, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
        id,
        foodId,
        foodNameSnapshot,
        mealType,
        grams,
        kcal,
        protein,
        carb,
        fat,
        isQuickAdd,
        loggedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLogEntryData &&
          other.id == id &&
          other.foodId == foodId &&
          other.foodNameSnapshot == foodNameSnapshot &&
          other.mealType == mealType &&
          other.grams == grams &&
          other.kcal == kcal &&
          other.protein == protein &&
          other.carb == carb &&
          other.fat == fat &&
          other.isQuickAdd == isQuickAdd &&
          other.loggedAt == loggedAt);
}

class FoodLogsCompanion extends UpdateCompanion<FoodLogEntryData> {
  final Value<String> id;
  final Value<String?> foodId;
  final Value<String> foodNameSnapshot;
  final Value<String> mealType;
  final Value<double?> grams;
  final Value<double> kcal;
  final Value<double> protein;
  final Value<double> carb;
  final Value<double> fat;
  final Value<bool> isQuickAdd;
  final Value<DateTime> loggedAt;

  const FoodLogsCompanion({
    this.id = const Value.absent(),
    this.foodId = const Value.absent(),
    this.foodNameSnapshot = const Value.absent(),
    this.mealType = const Value.absent(),
    this.grams = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.carb = const Value.absent(),
    this.fat = const Value.absent(),
    this.isQuickAdd = const Value.absent(),
    this.loggedAt = const Value.absent(),
  });

  FoodLogsCompanion.insert({
    required String id,
    this.foodId = const Value.absent(),
    required String foodNameSnapshot,
    required String mealType,
    this.grams = const Value.absent(),
    required double kcal,
    required double protein,
    required double carb,
    required double fat,
    this.isQuickAdd = const Value.absent(),
    required DateTime loggedAt,
  })  : id = Value(id),
        foodNameSnapshot = Value(foodNameSnapshot),
        mealType = Value(mealType),
        kcal = Value(kcal),
        protein = Value(protein),
        carb = Value(carb),
        fat = Value(fat),
        loggedAt = Value(loggedAt);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (foodNameSnapshot.present) {
      map['food_name_snapshot'] = Variable<String>(foodNameSnapshot.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carb.present) {
      map['carb'] = Variable<double>(carb.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (isQuickAdd.present) {
      map['is_quick_add'] = Variable<bool>(isQuickAdd.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    return map;
  }
}

class $FoodLogsTable extends FoodLogs with TableInfo<$FoodLogsTable, FoodLogEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogsTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
      'food_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false);

  static const VerificationMeta _foodNameSnapshotMeta = const VerificationMeta('foodNameSnapshot');
  @override
  late final GeneratedColumn<String> foodNameSnapshot = GeneratedColumn<String>(
      'food_name_snapshot', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  static const VerificationMeta _mealTypeMeta = const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true);

  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
      'grams', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false);

  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
      'kcal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _proteinMeta = const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _carbMeta = const VerificationMeta('carb');
  @override
  late final GeneratedColumn<double> carb = GeneratedColumn<double>(
      'carb', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: true);

  static const VerificationMeta _isQuickAddMeta = const VerificationMeta('isQuickAdd');
  @override
  late final GeneratedColumn<bool> isQuickAdd = GeneratedColumn<bool>(
      'is_quick_add', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK (is_quick_add IN (0, 1))'),
      defaultValue: const Constant(false));

  static const VerificationMeta _loggedAtMeta = const VerificationMeta('loggedAt');
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
      'logged_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);

  @override
  List<GeneratedColumn> get $columns => [
        id,
        foodId,
        foodNameSnapshot,
        mealType,
        grams,
        kcal,
        protein,
        carb,
        fat,
        isQuickAdd,
        loggedAt,
      ];

  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_logs';

  @override
  VerificationContext validateIntegrity(Insertable<FoodLogEntryData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta, foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    }
    if (data.containsKey('food_name_snapshot')) {
      context.handle(_foodNameSnapshotMeta, foodNameSnapshot.isAcceptableOrUnknown(data['food_name_snapshot']!, _foodNameSnapshotMeta));
    } else if (isInserting) {
      context.missing(_foodNameSnapshotMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta, mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(_gramsMeta, grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(_kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta, protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carb')) {
      context.handle(_carbMeta, carb.isAcceptableOrUnknown(data['carb']!, _carbMeta));
    } else if (isInserting) {
      context.missing(_carbMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(_fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('is_quick_add')) {
      context.handle(_isQuickAddMeta, isQuickAdd.isAcceptableOrUnknown(data['is_quick_add']!, _isQuickAddMeta));
    }
    if (data.containsKey('logged_at')) {
      context.handle(_loggedAtMeta, loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta));
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLogEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLogEntryData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      foodId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}food_id']),
      foodNameSnapshot: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}food_name_snapshot'])!,
      mealType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      grams: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}grams']),
      kcal: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}kcal'])!,
      protein: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
      carb: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}carb'])!,
      fat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      isQuickAdd: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_quick_add'])!,
      loggedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}logged_at'])!,
    );
  }

  @override
  $FoodLogsTable createAlias(String alias) {
    return $FoodLogsTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $FoodLogsTable foodLogs = $FoodLogsTable(this);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [foods, foodLogs];
}
