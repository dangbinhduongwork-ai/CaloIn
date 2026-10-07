import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validation_result.dart';
import 'macro_split.dart';

class ProfileValidator {
  ProfileValidator._();

  static ValidationResult validateAge(int? age) {
    if (age == null) {
      return ValidationResult.invalid('ageRequired', 'Tuổi không được để trống');
    }
    if (age < AppConstants.minAge) {
      return ValidationResult.invalid('underAge', 'Độ tuổi phải từ 18 trở lên');
    }
    if (age > AppConstants.maxAge) {
      return ValidationResult.invalid('ageTooHigh', 'Độ tuổi tối đa là 100');
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateHeight(double? heightCm) {
    if (heightCm == null) {
      return ValidationResult.invalid('heightRequired', 'Chiều cao không được để trống');
    }
    if (heightCm < AppConstants.minHeightCm) {
      return ValidationResult.invalid('heightTooLow', 'Chiều cao tối thiểu là 100 cm');
    }
    if (heightCm > AppConstants.maxHeightCm) {
      return ValidationResult.invalid('heightTooHigh', 'Chiều cao tối đa là 250 cm');
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateWeight(double? weightKg) {
    if (weightKg == null) {
      return ValidationResult.invalid('weightRequired', 'Cân nặng không được để trống');
    }
    if (weightKg < AppConstants.minWeightKg) {
      return ValidationResult.invalid('weightTooLow', 'Cân nặng tối thiểu là 30 kg');
    }
    if (weightKg > AppConstants.maxWeightKg) {
      return ValidationResult.invalid('weightTooHigh', 'Cân nặng tối đa là 300 kg');
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateMacroSplit(MacroSplit split) {
    if (split.proteinPct < 0 || split.carbPct < 0 || split.fatPct < 0) {
      return ValidationResult.invalid('macroNegative', 'Tỉ lệ macro không được âm');
    }
    if (split.total != 100) {
      return ValidationResult.invalid('macroSumNot100', 'Tổng tỉ lệ macro phải bằng 100%');
    }
    return ValidationResult.valid;
  }
}
