enum WeightUnit {
  kg,
  lb;

  bool get isKg => this == WeightUnit.kg;
  bool get isLb => this == WeightUnit.lb;
}

enum HeightUnit {
  cm,
  ftIn;

  bool get isCm => this == HeightUnit.cm;
  bool get isFtIn => this == HeightUnit.ftIn;
}

class UserSettings {
  const UserSettings({
    this.weightUnit = WeightUnit.kg,
    this.heightUnit = HeightUnit.cm,
  });

  final WeightUnit weightUnit;
  final HeightUnit heightUnit;

  UserSettings copyWith({
    WeightUnit? weightUnit,
    HeightUnit? heightUnit,
  }) {
    return UserSettings(
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          weightUnit == other.weightUnit &&
          heightUnit == other.heightUnit;

  @override
  int get hashCode => Object.hash(weightUnit, heightUnit);
}
