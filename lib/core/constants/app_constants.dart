class AppConstants {
  AppConstants._();

  // Age validation
  static const int minAge = 18;
  static const int maxAge = 100;

  // Height validation (cm)
  static const double minHeightCm = 100.0;
  static const double maxHeightCm = 250.0;

  // Weight validation (kg)
  static const double minWeightKg = 30.0;
  static const double maxWeightKg = 300.0;

  // Safe calorie floor (kcal/day)
  static const int maleCalorieFloor = 1500;
  static const int femaleCalorieFloor = 1200;

  // Weight goal calorie adjustments (kcal/day)
  static const int loseWeightCalorieDelta = -500;
  static const int gainWeightCalorieDelta = 300;
  static const int maintainWeightCalorieDelta = 0;

  // Macro calories per gram
  static const double proteinKcalPerGram = 4.0;
  static const double carbKcalPerGram = 4.0;
  static const double fatKcalPerGram = 9.0;

  // Default Macro Ratios (%)
  static const int defaultProteinPercentage = 20;
  static const int defaultCarbPercentage = 50;
  static const int defaultFatPercentage = 30;

  // Activity level multipliers (Mifflin-St Jeor TDEE)
  static const double sedentaryMultiplier = 1.2;
  static const double lightMultiplier = 1.375;
  static const double moderateMultiplier = 1.55;
  static const double veryActiveMultiplier = 1.725;
  static const double extraActiveMultiplier = 1.9;

  // Seed data version
  static const int currentSeedVersion = 1;

  // Shared preferences keys
  static const String prefHasCompletedOnboarding = 'has_completed_onboarding';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'app_language';
  static const String prefUnitSystem = 'unit_system';
  static const String prefHasConsentedBarcodeNetwork = 'has_consented_barcode_network';
}
