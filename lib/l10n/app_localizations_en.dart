// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CaloIn';

  @override
  String get disclaimer =>
      'Results are estimates only and do not replace professional medical or nutritional advice.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get undo => 'Undo';

  @override
  String get continueText => 'Continue';

  @override
  String get done => 'Done';

  @override
  String get copy => 'Copy';

  @override
  String get search => 'Search';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get warning => 'Warning';

  @override
  String get under18Warning =>
      'This app is intended for users 18 and older. Calorie calculation for under 18 is not supported. Please consult a doctor or guardian.';

  @override
  String floorWarning(int calories) {
    return 'Recommended calories adjusted to safe floor ($calories kcal) to preserve minimum metabolic health.';
  }

  @override
  String manualFloorWarning(int calories, int floor) {
    return 'The custom calorie target ($calories kcal) is below the safe floor ($floor kcal/day). Extreme calorie restriction can cause nutritional deficiencies. Are you sure you want to proceed?';
  }

  @override
  String exceedCalories(int calories) {
    return '$calories kcal over target';
  }

  @override
  String remainingCalories(int calories) {
    return '$calories kcal left';
  }

  @override
  String targetCalories(int calories) {
    return 'Target: $calories kcal';
  }

  @override
  String consumedCalories(int calories) {
    return 'Consumed: $calories kcal';
  }

  @override
  String get navDashboard => 'Today';

  @override
  String get navFoods => 'Foods';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get protein => 'Protein';

  @override
  String get carb => 'Carbohydrates';

  @override
  String get fat => 'Fat';

  @override
  String get proteinShort => 'Protein';

  @override
  String get carbShort => 'Carb';

  @override
  String get fatShort => 'Fat';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get age => 'Age';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get sedentary => 'Sedentary (desk job, little exercise)';

  @override
  String get lightActivity => 'Light (light exercise 1-3 days/week)';

  @override
  String get moderateActivity => 'Moderate (exercise 3-5 days/week)';

  @override
  String get veryActive => 'Very Active (hard exercise 6-7 days/week)';

  @override
  String get extraActive => 'Extra Active (athlete or physical labor)';

  @override
  String get goal => 'Goal';

  @override
  String get maintainWeight => 'Maintain weight';

  @override
  String get loseWeight => 'Lose weight (-500 kcal/day)';

  @override
  String get gainWeight => 'Gain weight (+300 kcal/day)';

  @override
  String get recentFoods => 'Recent';

  @override
  String get favoriteFoods => 'Favorites';

  @override
  String get allFoods => 'All Foods';

  @override
  String get copyYesterdayMeal => 'Copy this meal from yesterday';

  @override
  String get copyYesterdaySuccess => 'Copied items from yesterday';

  @override
  String get noYesterdayItems => 'No food logged for this meal yesterday';

  @override
  String get addCustomFood => 'Add Custom Food';

  @override
  String get quickAddCalories => 'Quick Add Calories';

  @override
  String get foodSearchPlaceholder => 'Search foods (e.g. pho bo, salad)...';

  @override
  String get servingSize => 'Serving Size';

  @override
  String get customFoodName => 'Food Name';

  @override
  String get quickAddName => 'Name / Description';

  @override
  String get kcalPer100g => 'Calories (kcal / 100g)';

  @override
  String get defaultServing => 'Default Serving (g)';

  @override
  String get servingUnit => 'Serving Unit (bowl, plate, pc...)';

  @override
  String get foodAddedSuccess => 'Food added to journal';

  @override
  String get foodDeleted => 'Food deleted';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get calorieTarget => 'Calorie Target';

  @override
  String get macroRatio => 'Macro Ratio';

  @override
  String get units => 'Units';

  @override
  String get metricUnit => 'Metric (kg, cm)';

  @override
  String get imperialUnit => 'Imperial (lb, ft/in)';

  @override
  String get language => 'Language';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get deleteAllData => 'Clear All Data';

  @override
  String get deleteAllDataConfirm =>
      'This action will permanently wipe all journal entries, custom foods, and profile settings. It cannot be undone.';

  @override
  String get dataClearedSuccess => 'All data has been cleared';

  @override
  String get bmrExplanation =>
      'BMR (Basal Metabolic Rate): Calories burned at complete rest.';

  @override
  String get tdeeExplanation =>
      'TDEE (Total Daily Energy Expenditure): BMR multiplied by your physical activity factor.';

  @override
  String get targetExplanation =>
      'Target calories = TDEE adjusted for weight goal (rounded to nearest 10 kcal).';

  @override
  String get formulaSummaryTitle => 'Estimated Energy Metrics';

  @override
  String get getStarted => 'Get Started';

  @override
  String get emptyDiary => 'No food entries logged for today yet';

  @override
  String get tapToAdd => 'Tap the + button to log your first food';

  @override
  String get dayView => 'Day';

  @override
  String get weekView => 'Week';

  @override
  String get monthView => 'Month';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get macroAverage => 'Macro Average';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryCarb => 'Carbs & Grains';

  @override
  String get categoryMeat => 'Meat & Poultry';

  @override
  String get categoryFishSeafood => 'Fish & Seafood';

  @override
  String get categoryEggDairy => 'Eggs & Dairy';

  @override
  String get categoryVegetable => 'Vegetables';

  @override
  String get categoryFruit => 'Fruits';

  @override
  String get categoryDrink => 'Beverages';

  @override
  String get categorySnack => 'Snacks';

  @override
  String get categoryOther => 'Other';

  @override
  String get noFoodsFound => 'No matching foods found';

  @override
  String estimatedFromMacros(String kcal) {
    return 'Estimated from macros: $kcal kcal';
  }

  @override
  String get servingUnitBowl => 'Bowl';

  @override
  String get servingUnitPlate => 'Plate';

  @override
  String get servingUnitPiece => 'Piece';

  @override
  String get servingUnitCup => 'Cup';

  @override
  String get servingUnitPortion => 'Portion';

  @override
  String get servingUnitCan => 'Can / Box';

  @override
  String get calories => 'Calories';

  @override
  String get macros => 'Macros';

  @override
  String get unlogged => 'Not logged';

  @override
  String get loggedDaysCount => 'Days logged';

  @override
  String get highestDayLabel => 'Highest day';

  @override
  String get lowestDayLabel => 'Lowest day';

  @override
  String get noHistoryData => 'No data logged in this period';

  @override
  String get generateSampleData => 'Generate 60-day sample data (Debug)';

  @override
  String get sampleDataGenerated =>
      'Successfully generated 60 days of sample data';

  @override
  String get macroRatioTitle => 'Macro Ratio';

  @override
  String get historySummaryTitle => 'Nutrition Summary';

  @override
  String get mealsBreakdown => 'Meals Breakdown';

  @override
  String get chartSemantics => 'Calories and nutrition chart';

  @override
  String get profileSection => 'Profile & Goals';

  @override
  String get editGoals => 'Edit Goals & Macros';

  @override
  String get editFullProfile => 'Edit Personal Info';

  @override
  String get weightUnitLabel => 'Weight Unit';

  @override
  String get heightUnitLabel => 'Height Unit';

  @override
  String get appearanceLanguageSection => 'Appearance & Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get dataSection => 'Data Management';

  @override
  String get manageFoods => 'Food Library & Custom Foods';

  @override
  String get manageFoodsSubtitle =>
      'Browse foods, create and manage custom items';

  @override
  String get aboutApp => 'About & Calculation Methods';

  @override
  String get aboutAppSubtitle =>
      'Version, Mifflin-St Jeor formulas, sources & medical disclaimer';

  @override
  String get clearAndReset => 'Clear & Reset';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get goalsUpdatedSuccess => 'Goals updated successfully';

  @override
  String get appVersionLabel => 'Version: 1.0.0';

  @override
  String get safeFloorInfo =>
      'Safe calorie floor: Female min 1200 kcal/day, Male min 1500 kcal/day.';

  @override
  String get medicalDisclaimerFull =>
      'CaloIn is strictly for adults 18+. Estimates are for informational purposes and do not replace professional medical advice, diagnosis, or treatment.';

  @override
  String get dataSourceInfo =>
      'Nutritional data is compiled from the National Institute of Nutrition (Vietnam) and USDA FoodData Central, cross-checked with Atwater factors (deviation ≤ 20%).';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get barcodeLookupConsentTitle => 'Online Barcode Lookup';

  @override
  String get barcodeLookupConsentDesc =>
      'To look up food data, the product barcode will be sent to the open database Open Food Facts via the Internet. Do you want to proceed?';

  @override
  String get cameraPermissionDeniedTitle => 'Camera Permission Denied';

  @override
  String get cameraPermissionDeniedDesc =>
      'CaloIn requires camera permission to scan product barcodes.';

  @override
  String get manualEntry => 'Enter Manually';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get barcodeNotFoundTitle => 'Product Not Found';

  @override
  String get barcodeNotFoundDesc =>
      'Barcode not found in Open Food Facts database. You can manually enter this food item.';

  @override
  String get networkErrorTitle => 'No Internet Connection';

  @override
  String get networkErrorDesc =>
      'Cannot connect to the Internet for lookup. Please check your network or enter manually.';

  @override
  String get timeoutTitle => 'Request Timeout';

  @override
  String get timeoutDesc =>
      'Lookup request timed out (10 seconds). Please try again or enter manually.';

  @override
  String get incompleteNutritionTitle => 'Incomplete Nutrition Data';

  @override
  String get incompleteNutritionDesc =>
      'Product found, but calories/macros are incomplete on Open Food Facts. Please fill in the missing values.';

  @override
  String get viewfinderHint => 'Align barcode within the viewfinder';

  @override
  String get searchingBarcode => 'Searching Open Food Facts...';

  @override
  String get openFoodFactsAttribution =>
      'Barcode data sourced from Open Food Facts (ODbL).';
}
