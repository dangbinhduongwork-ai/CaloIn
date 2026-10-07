class Nutrition {
  const Nutrition({
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
  });

  final double kcal;
  final double protein;
  final double carb;
  final double fat;

  static const Nutrition zero = Nutrition(
    kcal: 0.0,
    protein: 0.0,
    carb: 0.0,
    fat: 0.0,
  );

  Nutrition operator +(Nutrition other) {
    return Nutrition(
      kcal: kcal + other.kcal,
      protein: protein + other.protein,
      carb: carb + other.carb,
      fat: fat + other.fat,
    );
  }

  Nutrition operator *(double factor) {
    return Nutrition(
      kcal: kcal * factor,
      protein: protein * factor,
      carb: carb * factor,
      fat: fat * factor,
    );
  }

  Nutrition copyWith({
    double? kcal,
    double? protein,
    double? carb,
    double? fat,
  }) {
    return Nutrition(
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carb: carb ?? this.carb,
      fat: fat ?? this.fat,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Nutrition &&
          runtimeType == other.runtimeType &&
          (kcal - other.kcal).abs() < 1e-4 &&
          (protein - other.protein).abs() < 1e-4 &&
          (carb - other.carb).abs() < 1e-4 &&
          (fat - other.fat).abs() < 1e-4;

  @override
  int get hashCode => Object.hash(
        (kcal * 100).round(),
        (protein * 100).round(),
        (carb * 100).round(),
        (fat * 100).round(),
      );

  @override
  String toString() =>
      'Nutrition(${kcal.toStringAsFixed(1)} kcal, P: ${protein.toStringAsFixed(1)}g, C: ${carb.toStringAsFixed(1)}g, F: ${fat.toStringAsFixed(1)}g)';
}
