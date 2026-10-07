import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(instance != null, 'No instance of AppLocalizations found in BuildContext.');
    return instance!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('vi'),
    Locale('en'),
  ];

  String get appName;
  String get disclaimer;
  String get save;
  String get cancel;
  String get delete;
  String get edit;
  String get undo;
  String get continueText;
  String get done;
  String get copy;
  String get search;
  String get add;
  String get close;
  String get confirm;
  String get warning;
  String get under18Warning;
  String floorWarning(int calories);
  String manualFloorWarning(int calories, int floor);
  String exceedCalories(int calories);
  String remainingCalories(int calories);
  String targetCalories(int calories);
  String consumedCalories(int calories);
  String get navDashboard;
  String get navFoods;
  String get navHistory;
  String get navSettings;
  String get breakfast;
  String get lunch;
  String get dinner;
  String get snack;
  String get protein;
  String get carb;
  String get fat;
  String get proteinShort;
  String get carbShort;
  String get fatShort;
  String get gender;
  String get male;
  String get female;
  String get age;
  String get height;
  String get weight;
  String get activityLevel;
  String get sedentary;
  String get lightActivity;
  String get moderateActivity;
  String get veryActive;
  String get extraActive;
  String get goal;
  String get maintainWeight;
  String get loseWeight;
  String get gainWeight;
  String get recentFoods;
  String get favoriteFoods;
  String get allFoods;
  String get copyYesterdayMeal;
  String get copyYesterdaySuccess;
  String get noYesterdayItems;
  String get addCustomFood;
  String get quickAddCalories;
  String get foodSearchPlaceholder;
  String get servingSize;
  String get customFoodName;
  String get quickAddName;
  String get kcalPer100g;
  String get defaultServing;
  String get servingUnit;
  String get foodAddedSuccess;
  String get foodDeleted;
  String get editProfile;
  String get calorieTarget;
  String get macroRatio;
  String get units;
  String get metricUnit;
  String get imperialUnit;
  String get language;
  String get themeMode;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get deleteAllData;
  String get deleteAllDataConfirm;
  String get dataClearedSuccess;
  String get bmrExplanation;
  String get tdeeExplanation;
  String get targetExplanation;
  String get formulaSummaryTitle;
  String get getStarted;
  String get emptyDiary;
  String get tapToAdd;
  String get dayView;
  String get weekView;
  String get monthView;
  String get dailyAverage;
  String get macroAverage;

  // Food categories & units
  String get categoryAll;
  String get categoryCarb;
  String get categoryMeat;
  String get categoryFishSeafood;
  String get categoryEggDairy;
  String get categoryVegetable;
  String get categoryFruit;
  String get categoryDrink;
  String get categorySnack;
  String get categoryOther;
  String get noFoodsFound;
  String estimatedFromMacros(String kcal);
  String get servingUnitBowl;
  String get servingUnitPlate;
  String get servingUnitPiece;
  String get servingUnitCup;
  String get servingUnitPortion;
  String get servingUnitCan;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    if (locale.languageCode == 'en') {
      return SynchronousFuture<AppLocalizations>(AppLocalizationsEn(locale));
    }
    return SynchronousFuture<AppLocalizations>(AppLocalizationsVi(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi(super.locale);

  @override
  String get appName => 'CaloIn';

  @override
  String get disclaimer => 'Kết quả chỉ mang tính ước lượng, không thay thế tư vấn y tế hoặc dinh dưỡng.';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get continueText => 'Tiếp tục';

  @override
  String get done => 'Xong';

  @override
  String get copy => 'Sao chép';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get add => 'Thêm';

  @override
  String get close => 'Đóng';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get warning => 'Cảnh báo';

  @override
  String get under18Warning => 'Ứng dụng chỉ dành cho người từ 18 tuổi trở lên. Nhu cầu dinh dưỡng ở độ tuổi dưới 18 đang phát triển và cần được tư vấn bởi bác sĩ hoặc phụ huynh.';

  @override
  String floorWarning(int calories) => 'Mức calo tính toán đã được nâng lên mức sàn an toàn ($calories kcal) để đảm bảo năng lượng tối thiểu cho cơ thể.';

  @override
  String manualFloorWarning(int calories, int floor) => 'Mức calo bạn nhập ($calories kcal) thấp hơn mức sàn an toàn ($floor kcal/ngày). Cắt giảm calo quá thấp có thể gây suy nhược và ảnh hưởng sức khỏe. Bạn có chắc chắn muốn tiếp tục?';

  @override
  String exceedCalories(int calories) => 'Đã nạp hơn $calories kcal so với mục tiêu';

  @override
  String remainingCalories(int calories) => 'Còn lại $calories kcal';

  @override
  String targetCalories(int calories) => 'Mục tiêu: $calories kcal';

  @override
  String consumedCalories(int calories) => 'Đã nạp: $calories kcal';

  @override
  String get navDashboard => 'Hôm nay';

  @override
  String get navFoods => 'Món ăn';

  @override
  String get navHistory => 'Lịch sử';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get breakfast => 'Bữa sáng';

  @override
  String get lunch => 'Bữa trưa';

  @override
  String get dinner => 'Bữa tối';

  @override
  String get snack => 'Bữa phụ';

  @override
  String get protein => 'Chất đạm (Protein)';

  @override
  String get carb => 'Tinh bột (Carb)';

  @override
  String get fat => 'Chất béo (Fat)';

  @override
  String get proteinShort => 'Protein';

  @override
  String get carbShort => 'Carb';

  @override
  String get fatShort => 'Fat';

  @override
  String get gender => 'Giới tính';

  @override
  String get male => 'Nam';

  @override
  String get female => 'Nữ';

  @override
  String get age => 'Tuổi';

  @override
  String get height => 'Chiều cao';

  @override
  String get weight => 'Cân nặng';

  @override
  String get activityLevel => 'Mức độ vận động';

  @override
  String get sedentary => 'Ít vận động (ngồi nhiều, không tập thể dục)';

  @override
  String get lightActivity => 'Vận động nhẹ (tập luyện nhẹ 1-3 ngày/tuần)';

  @override
  String get moderateActivity => 'Vận động vừa (tập thể thao 3-5 ngày/tuần)';

  @override
  String get veryActive => 'Vận động nhiều (tập nặng 6-7 ngày/tuần)';

  @override
  String get extraActive => 'Rất nhiều (vận động viên / lao động thể lực)';

  @override
  String get goal => 'Mục tiêu thể trạng';

  @override
  String get maintainWeight => 'Giữ cân';

  @override
  String get loseWeight => 'Giảm cân (-500 kcal/ngày)';

  @override
  String get gainWeight => 'Tăng cân (+300 kcal/ngày)';

  @override
  String get recentFoods => 'Gần đây';

  @override
  String get favoriteFoods => 'Yêu thích';

  @override
  String get allFoods => 'Tất cả';

  @override
  String get copyYesterdayMeal => 'Sao chép bữa này từ hôm qua';

  @override
  String get copyYesterdaySuccess => 'Đã sao chép các món từ hôm qua';

  @override
  String get noYesterdayItems => 'Không có món nào ở bữa này hôm qua';

  @override
  String get addCustomFood => 'Thêm món tùy chỉnh';

  @override
  String get quickAddCalories => 'Thêm nhanh calo';

  @override
  String get foodSearchPlaceholder => 'Tìm món ăn (vd: pho bo, com tam)...';

  @override
  String get servingSize => 'Khẩu phần';

  @override
  String get customFoodName => 'Tên món ăn';

  @override
  String get quickAddName => 'Tên món / mô tả';

  @override
  String get kcalPer100g => 'Calo (kcal / 100g)';

  @override
  String get defaultServing => 'Khẩu phần mặc định (g)';

  @override
  String get servingUnit => 'Đơn vị tính (bát, đĩa, cái...)';

  @override
  String get foodAddedSuccess => 'Đã thêm món vào nhật ký';

  @override
  String get foodDeleted => 'Đã xóa món ăn';

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get calorieTarget => 'Mục tiêu calo';

  @override
  String get macroRatio => 'Tỉ lệ phân bổ macro';

  @override
  String get units => 'Đơn vị đo';

  @override
  String get metricUnit => 'Hệ Mét (kg, cm)';

  @override
  String get imperialUnit => 'Hệ Anh-Mỹ (lb, ft/in)';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get themeMode => 'Giao diện';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get deleteAllData => 'Xóa toàn bộ dữ liệu';

  @override
  String get deleteAllDataConfirm => 'Hành động này sẽ xóa vĩnh viễn toàn bộ nhật ký, món tùy chỉnh và hồ sơ. Bạn không thể hoàn tác.';

  @override
  String get dataClearedSuccess => 'Đã xóa toàn bộ dữ liệu';

  @override
  String get bmrExplanation => 'BMR (Chỉ số trao đổi chất cơ bản): Năng lượng cơ thể tiêu thụ khi nghỉ ngơi hoàn toàn.';

  @override
  String get tdeeExplanation => 'TDEE (Tổng năng lượng tiêu hao hằng ngày): BMR nhân với hệ số vận động.';

  @override
  String get targetExplanation => 'Mục tiêu calo = TDEE điều chỉnh theo mục tiêu cân nặng (làm tròn đến 10 kcal).';

  @override
  String get formulaSummaryTitle => 'Chỉ số năng lượng ước tính';

  @override
  String get getStarted => 'Bắt đầu sử dụng';

  @override
  String get emptyDiary => 'Chưa có món ăn nào trong ngày hôm nay';

  @override
  String get tapToAdd => 'Chạm vào nút + để ghi món đầu tiên';

  @override
  String get dayView => 'Ngày';

  @override
  String get weekView => 'Tuần';

  @override
  String get monthView => 'Tháng';

  @override
  String get dailyAverage => 'Trung bình/ngày';

  @override
  String get macroAverage => 'Macro trung bình';

  @override
  String get categoryAll => 'Tất cả';

  @override
  String get categoryCarb => 'Tinh bột';

  @override
  String get categoryMeat => 'Thịt';

  @override
  String get categoryFishSeafood => 'Cá & Hải sản';

  @override
  String get categoryEggDairy => 'Trứng & Sữa';

  @override
  String get categoryVegetable => 'Rau củ';

  @override
  String get categoryFruit => 'Trái cây';

  @override
  String get categoryDrink => 'Đồ uống';

  @override
  String get categorySnack => 'Ăn vặt';

  @override
  String get categoryOther => 'Khác';

  @override
  String get noFoodsFound => 'Không tìm thấy món ăn nào phù hợp';

  @override
  String estimatedFromMacros(String kcal) => 'Ước tính từ macro: $kcal kcal';

  @override
  String get servingUnitBowl => 'Tô / Bát';

  @override
  String get servingUnitPlate => 'Đĩa / Dĩa';

  @override
  String get servingUnitPiece => 'Cái / Chiếc / Quả';

  @override
  String get servingUnitCup => 'Ly / Cốc';

  @override
  String get servingUnitPortion => 'Phần / Suất';

  @override
  String get servingUnitCan => 'Lon / Hộp';
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn(super.locale);

  @override
  String get appName => 'CaloIn';

  @override
  String get disclaimer => 'Results are estimates only and do not replace professional medical or nutritional advice.';

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
  String get under18Warning => 'This app is intended for users 18 and older. Calorie calculation for under 18 is not supported. Please consult a doctor or guardian.';

  @override
  String floorWarning(int calories) => 'Recommended calories adjusted to safe floor ($calories kcal) to preserve minimum metabolic health.';

  @override
  String manualFloorWarning(int calories, int floor) => 'The custom calorie target ($calories kcal) is below the safe floor ($floor kcal/day). Extreme calorie restriction can cause nutritional deficiencies. Are you sure you want to proceed?';

  @override
  String exceedCalories(int calories) => '$calories kcal over target';

  @override
  String remainingCalories(int calories) => '$calories kcal left';

  @override
  String targetCalories(int calories) => 'Target: $calories kcal';

  @override
  String consumedCalories(int calories) => 'Consumed: $calories kcal';

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
  String get deleteAllDataConfirm => 'This action will permanently wipe all journal entries, custom foods, and profile settings. It cannot be undone.';

  @override
  String get dataClearedSuccess => 'All data has been cleared';

  @override
  String get bmrExplanation => 'BMR (Basal Metabolic Rate): Calories burned at complete rest.';

  @override
  String get tdeeExplanation => 'TDEE (Total Daily Energy Expenditure): BMR multiplied by your physical activity factor.';

  @override
  String get targetExplanation => 'Target calories = TDEE adjusted for weight goal (rounded to nearest 10 kcal).';

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
  String estimatedFromMacros(String kcal) => 'Estimated from macros: $kcal kcal';

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
}
