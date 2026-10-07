class AppFormatters {
  AppFormatters._();

  /// Format kcal as rounded integer string (e.g. "1234")
  static String formatKcal(double kcal) {
    return kcal.round().toString();
  }

  /// Format kcal with unit (e.g. "1234 kcal")
  static String formatKcalWithUnit(double kcal) {
    return '${formatKcal(kcal)} kcal';
  }

  /// Format macro with 1 decimal place (e.g. "25.5")
  static String formatMacro(double grams) {
    return grams.toStringAsFixed(1);
  }

  /// Format macro with unit (e.g. "25.5 g")
  static String formatMacroWithUnit(double grams) {
    return '${formatMacro(grams)} g';
  }

  /// Format percentage (e.g. "20%")
  static String formatPercentage(double pct) {
    return '${pct.round()}%';
  }

  /// Format weight with unit depending on unit system
  static String formatWeight(double kg, {bool isMetric = true}) {
    if (isMetric) {
      return '${kg.toStringAsFixed(1)} kg';
    } else {
      final lb = kg * 2.20462262185;
      return '${lb.toStringAsFixed(1)} lb';
    }
  }

  /// Format height with unit depending on unit system
  static String formatHeight(double cm, {bool isMetric = true}) {
    if (isMetric) {
      return '${cm.round()} cm';
    } else {
      final totalInches = cm / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = totalInches - (feet * 12);
      return '$feet\'${inches.round()}"';
    }
  }
}
