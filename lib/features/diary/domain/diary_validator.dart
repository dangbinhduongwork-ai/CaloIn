import '../../core/utils/validation_result.dart';

class DiaryValidator {
  DiaryValidator._();

  static const double minGrams = 1.0;
  static const double maxGrams = 5000.0;
  static const double minQuickAddKcal = 1.0;
  static const double maxQuickAddKcal = 10000.0;

  static ValidationResult validateGrams(double? grams) {
    if (grams == null) {
      return ValidationResult.invalid('gramsRequired', 'Khối lượng không được để trống');
    }
    if (grams < minGrams) {
      return ValidationResult.invalid('gramsTooLow', 'Khối lượng tối thiểu là 1g');
    }
    if (grams > maxGrams) {
      return ValidationResult.invalid('gramsTooHigh', 'Khối lượng tối đa là 5000g');
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateQuickAddKcal(double? kcal) {
    if (kcal == null) {
      return ValidationResult.invalid('kcalRequired', 'Lượng calo không được để trống');
    }
    if (kcal < minQuickAddKcal) {
      return ValidationResult.invalid('kcalTooLow', 'Lượng calo tối thiểu là 1 kcal');
    }
    if (kcal > maxQuickAddKcal) {
      return ValidationResult.invalid('kcalTooHigh', 'Lượng calo tối đa là 10000 kcal');
    }
    return ValidationResult.valid;
  }
}
