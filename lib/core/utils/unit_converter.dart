class FeetInches {
  const FeetInches({
    required this.feet,
    required this.inches,
  });

  final int feet;
  final double inches;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeetInches &&
          runtimeType == other.runtimeType &&
          feet == other.feet &&
          (inches - other.inches).abs() < 1e-6;

  @override
  int get hashCode => Object.hash(feet, inches);

  @override
  String toString() => '$feet ft ${inches.toStringAsFixed(1)} in';
}

class UnitConverter {
  UnitConverter._();

  static const double _lbPerKg = 2.20462262185;
  static const double _kgPerLb = 0.45359237;
  static const double _cmPerInch = 2.54;
  static const int _inchesPerFoot = 12;

  /// Convert kilograms to pounds
  static double kgToLb(double kg) => kg * _lbPerKg;

  /// Convert pounds to kilograms
  static double lbToKg(double lb) => lb * _kgPerLb;

  /// Convert centimeters to feet and inches
  static FeetInches cmToFtIn(double cm) {
    if (cm <= 0) return const FeetInches(feet: 0, inches: 0.0);
    final totalInches = cm / _cmPerInch;
    final feet = (totalInches / _inchesPerFoot).floor();
    final inches = totalInches - (feet * _inchesPerFoot);
    return FeetInches(feet: feet, inches: inches);
  }

  /// Convert feet and inches to centimeters
  static double ftInToCm(int feet, double inches) {
    final totalInches = (feet * _inchesPerFoot) + inches;
    return totalInches * _cmPerInch;
  }
}
