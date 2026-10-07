import '../../../core/constants/app_constants.dart';
import 'macro_split.dart';

class MacroGramsResult {
  const MacroGramsResult({
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
  });

  final double proteinGrams;
  final double carbGrams;
  final double fatGrams;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MacroGramsResult &&
          runtimeType == other.runtimeType &&
          (proteinGrams - other.proteinGrams).abs() < 1e-4 &&
          (carbGrams - other.carbGrams).abs() < 1e-4 &&
          (fatGrams - other.fatGrams).abs() < 1e-4;

  @override
  int get hashCode => Object.hash(proteinGrams, carbGrams, fatGrams);

  @override
  String toString() =>
      'MacroGramsResult(P: ${proteinGrams.toStringAsFixed(1)}g, C: ${carbGrams.toStringAsFixed(1)}g, F: ${fatGrams.toStringAsFixed(1)}g)';
}

class MacroCalculator {
  MacroCalculator._();

  /// Converts target kcal and MacroSplit into grams:
  /// protein (g) = (kcal * protein%) / 4
  /// carb (g) = (kcal * carb%) / 4
  /// fat (g) = (kcal * fat%) / 9
  static MacroGramsResult calculateGrams({
    required int targetKcal,
    required MacroSplit macroSplit,
  }) {
    final proteinKcal = targetKcal * (macroSplit.proteinPct / 100.0);
    final carbKcal = targetKcal * (macroSplit.carbPct / 100.0);
    final fatKcal = targetKcal * (macroSplit.fatPct / 100.0);

    return MacroGramsResult(
      proteinGrams: proteinKcal / AppConstants.proteinKcalPerGram,
      carbGrams: carbKcal / AppConstants.carbKcalPerGram,
      fatGrams: fatKcal / AppConstants.fatKcalPerGram,
    );
  }

  /// Calculates total kcal from macro grams:
  /// kcal = protein * 4 + carb * 4 + fat * 9
  static double calculateKcalFromMacros({
    required double proteinGrams,
    required double carbGrams,
    required double fatGrams,
  }) {
    return (proteinGrams * AppConstants.proteinKcalPerGram) +
        (carbGrams * AppConstants.carbKcalPerGram) +
        (fatGrams * AppConstants.fatKcalPerGram);
  }
}
