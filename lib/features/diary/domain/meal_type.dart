enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  bool get isBreakfast => this == MealType.breakfast;
  bool get isLunch => this == MealType.lunch;
  bool get isDinner => this == MealType.dinner;
  bool get isSnack => this == MealType.snack;
}
