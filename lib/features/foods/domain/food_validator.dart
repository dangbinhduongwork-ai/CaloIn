import '../../core/utils/validation_result.dart';

class FoodValidator {
  FoodValidator._();

  static ValidationResult validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.invalid('nameRequired', 'Tên món không được để trống');
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateKcalPer100g(double? kcal) {
    if (kcal == null) {
      return ValidationResult.invalid('kcalRequired', 'Lượng calo không được để trống');
    }
    if (kcal < 0) {
      return ValidationResult.invalid('kcalNegative', 'Lượng calo không được âm');
    }
    if (kcal > 900) {
      return ValidationResult.invalid('kcalTooHigh', 'Lượng calo tối đa là 900 kcal/100g');
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateMacro(String nutrientName, double? value) {
    if (value == null) {
      return ValidationResult.invalid('${nutrientName}Required', '$nutrientName không được để trống');
    }
    if (value < 0) {
      return ValidationResult.invalid('${nutrientName}Negative', '$nutrientName không được âm');
    }
    if (value > 100) {
      return ValidationResult.invalid('${nutrientName}TooHigh', '$nutrientName tối đa là 100g/100g');
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateCustomFood({
    required String name,
    required double kcalPer100g,
    required double proteinPer100g,
    required double carbPer100g,
    required double fatPer100g,
  }) {
    final nameResult = validateName(name);
    if (!nameResult.isValid) return nameResult;

    final kcalResult = validateKcalPer100g(kcalPer100g);
    if (!kcalResult.isValid) return kcalResult;

    final proteinResult = validateMacro('protein', proteinPer100g);
    if (!proteinResult.isValid) return proteinResult;

    final carbResult = validateMacro('carb', carbPer100g);
    if (!carbResult.isValid) return carbResult;

    final fatResult = validateMacro('fat', fatPer100g);
    if (!fatResult.isValid) return fatResult;

    // Tolerance of 0.5 for rounding/measurement discrepancies
    if ((proteinPer100g + carbPer100g + fatPer100g) > 100.5) {
      return ValidationResult.invalid(
        'macroSumExceeds100',
        'Tổng khối lượng protein, carb, fat không được vượt quá 100g (trên 100g thực phẩm)',
      );
    }

    return ValidationResult.valid;
  }
}
