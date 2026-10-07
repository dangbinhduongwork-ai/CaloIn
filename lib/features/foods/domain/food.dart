import 'nutrition.dart';

class Food {
  const Food({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbPer100g,
    required this.fatPer100g,
    required this.defaultServingGrams,
    required this.servingLabelKey,
    required this.category,
    this.isCustom = false,
    this.isFavorite = false,
    this.dataQuality = 'estimated',
  });

  final String id;
  final String nameVi;
  final String nameEn;
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

  Nutrition get nutritionPer100g => Nutrition(
        kcal: kcalPer100g,
        protein: proteinPer100g,
        carb: carbPer100g,
        fat: fatPer100g,
      );

  Food copyWith({
    String? id,
    String? nameVi,
    String? nameEn,
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
  }) {
    return Food(
      id: id ?? this.id,
      nameVi: nameVi ?? this.nameVi,
      nameEn: nameEn ?? this.nameEn,
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
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Food &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nameVi == other.nameVi &&
          nameEn == other.nameEn &&
          (kcalPer100g - other.kcalPer100g).abs() < 1e-4 &&
          (proteinPer100g - other.proteinPer100g).abs() < 1e-4 &&
          (carbPer100g - other.carbPer100g).abs() < 1e-4 &&
          (fatPer100g - other.fatPer100g).abs() < 1e-4 &&
          (defaultServingGrams - other.defaultServingGrams).abs() < 1e-4 &&
          servingLabelKey == other.servingLabelKey &&
          category == other.category &&
          isCustom == other.isCustom &&
          isFavorite == other.isFavorite &&
          dataQuality == other.dataQuality;

  @override
  int get hashCode => Object.hash(
        id,
        nameVi,
        nameEn,
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
  String toString() => 'Food($nameVi / $nameEn: ${kcalPer100g}kcal/100g)';
}
