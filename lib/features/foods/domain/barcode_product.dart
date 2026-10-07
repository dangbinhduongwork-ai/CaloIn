import 'food.dart';

class BarcodeProduct {
  const BarcodeProduct({
    required this.barcode,
    required this.name,
    this.brand,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbPer100g,
    required this.fatPer100g,
    required this.defaultServingGrams,
    required this.servingLabel,
    this.imageUrl,
    this.hasCompleteNutrition = true,
  });

  final String barcode;
  final String name;
  final String? brand;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbPer100g;
  final double fatPer100g;
  final double defaultServingGrams;
  final String servingLabel;
  final String? imageUrl;
  final bool hasCompleteNutrition;

  String get displayName => brand != null && brand!.isNotEmpty ? '$name ($brand)' : name;

  Food toCustomFood({String category = 'other'}) {
    return Food(
      id: 'custom_bc_$barcode',
      nameVi: displayName,
      nameEn: displayName,
      kcalPer100g: kcalPer100g,
      proteinPer100g: proteinPer100g,
      carbPer100g: carbPer100g,
      fatPer100g: fatPer100g,
      defaultServingGrams: defaultServingGrams > 0 ? defaultServingGrams : 100.0,
      servingLabelKey: servingLabel.isNotEmpty ? servingLabel : 'portion',
      category: category,
      isCustom: true,
      dataQuality: 'community',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeProduct &&
          runtimeType == other.runtimeType &&
          barcode == other.barcode &&
          name == other.name &&
          brand == other.brand &&
          kcalPer100g == other.kcalPer100g &&
          proteinPer100g == other.proteinPer100g &&
          carbPer100g == other.carbPer100g &&
          fatPer100g == other.fatPer100g &&
          defaultServingGrams == other.defaultServingGrams &&
          servingLabel == other.servingLabel &&
          hasCompleteNutrition == other.hasCompleteNutrition;

  @override
  int get hashCode => Object.hash(
        barcode,
        name,
        brand,
        kcalPer100g,
        proteinPer100g,
        carbPer100g,
        fatPer100g,
        defaultServingGrams,
        servingLabel,
        hasCompleteNutrition,
      );
}
