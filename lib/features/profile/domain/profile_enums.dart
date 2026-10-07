enum Gender {
  male,
  female;

  bool get isMale => this == Gender.male;
  bool get isFemale => this == Gender.female;
}

enum ActivityLevel {
  sedentary(1.2),
  light(1.375),
  moderate(1.55),
  veryActive(1.725),
  extraActive(1.9);

  const ActivityLevel(this.factor);

  final double factor;
}

enum Goal {
  lose(-500),
  maintain(0),
  gain(300);

  const Goal(this.calorieDelta);

  final int calorieDelta;
}
