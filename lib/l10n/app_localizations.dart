import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'CaloIn'**
  String get appName;

  /// No description provided for @disclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả chỉ mang tính ước lượng, không thay thế tư vấn y tế hoặc dinh dưỡng.'**
  String get disclaimer;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get edit;

  /// No description provided for @undo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get undo;

  /// No description provided for @continueText.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get continueText;

  /// No description provided for @done.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get done;

  /// No description provided for @copy.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get copy;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get add;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @warning.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo'**
  String get warning;

  /// No description provided for @under18Warning.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng chỉ dành cho người từ 18 tuổi trở lên. Nhu cầu dinh dưỡng ở độ tuổi dưới 18 đang phát triển và cần được tư vấn bởi bác sĩ hoặc phụ huynh.'**
  String get under18Warning;

  /// No description provided for @floorWarning.
  ///
  /// In vi, this message translates to:
  /// **'Mức calo tính toán đã được nâng lên mức sàn an toàn ({calories} kcal) để đảm bảo năng lượng tối thiểu cho cơ thể.'**
  String floorWarning(int calories);

  /// No description provided for @manualFloorWarning.
  ///
  /// In vi, this message translates to:
  /// **'Mức calo bạn nhập ({calories} kcal) thấp hơn mức sàn an toàn ({floor} kcal/ngày). Cắt giảm calo quá thấp có thể gây suy nhược và ảnh hưởng sức khỏe. Bạn có chắc chắn muốn tiếp tục?'**
  String manualFloorWarning(int calories, int floor);

  /// No description provided for @exceedCalories.
  ///
  /// In vi, this message translates to:
  /// **'Đã nạp hơn {calories} kcal so với mục tiêu'**
  String exceedCalories(int calories);

  /// No description provided for @remainingCalories.
  ///
  /// In vi, this message translates to:
  /// **'Còn lại {calories} kcal'**
  String remainingCalories(int calories);

  /// No description provided for @targetCalories.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu: {calories} kcal'**
  String targetCalories(int calories);

  /// No description provided for @consumedCalories.
  ///
  /// In vi, this message translates to:
  /// **'Đã nạp: {calories} kcal'**
  String consumedCalories(int calories);

  /// No description provided for @navDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get navDashboard;

  /// No description provided for @navFoods.
  ///
  /// In vi, this message translates to:
  /// **'Món ăn'**
  String get navFoods;

  /// No description provided for @navHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get navSettings;

  /// No description provided for @breakfast.
  ///
  /// In vi, this message translates to:
  /// **'Bữa sáng'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In vi, this message translates to:
  /// **'Bữa trưa'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In vi, this message translates to:
  /// **'Bữa tối'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In vi, this message translates to:
  /// **'Bữa phụ'**
  String get snack;

  /// No description provided for @protein.
  ///
  /// In vi, this message translates to:
  /// **'Chất đạm (Protein)'**
  String get protein;

  /// No description provided for @carb.
  ///
  /// In vi, this message translates to:
  /// **'Tinh bột (Carb)'**
  String get carb;

  /// No description provided for @fat.
  ///
  /// In vi, this message translates to:
  /// **'Chất béo (Fat)'**
  String get fat;

  /// No description provided for @proteinShort.
  ///
  /// In vi, this message translates to:
  /// **'Protein'**
  String get proteinShort;

  /// No description provided for @carbShort.
  ///
  /// In vi, this message translates to:
  /// **'Carb'**
  String get carbShort;

  /// No description provided for @fatShort.
  ///
  /// In vi, this message translates to:
  /// **'Fat'**
  String get fatShort;

  /// No description provided for @gender.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get male;

  /// No description provided for @female.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get female;

  /// No description provided for @age.
  ///
  /// In vi, this message translates to:
  /// **'Tuổi'**
  String get age;

  /// No description provided for @height.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng'**
  String get weight;

  /// No description provided for @activityLevel.
  ///
  /// In vi, this message translates to:
  /// **'Mức độ vận động'**
  String get activityLevel;

  /// No description provided for @sedentary.
  ///
  /// In vi, this message translates to:
  /// **'Ít vận động (ngồi nhiều, không tập thể dục)'**
  String get sedentary;

  /// No description provided for @lightActivity.
  ///
  /// In vi, this message translates to:
  /// **'Vận động nhẹ (tập luyện nhẹ 1-3 ngày/tuần)'**
  String get lightActivity;

  /// No description provided for @moderateActivity.
  ///
  /// In vi, this message translates to:
  /// **'Vận động vừa (tập thể thao 3-5 ngày/tuần)'**
  String get moderateActivity;

  /// No description provided for @veryActive.
  ///
  /// In vi, this message translates to:
  /// **'Vận động nhiều (tập nặng 6-7 ngày/tuần)'**
  String get veryActive;

  /// No description provided for @extraActive.
  ///
  /// In vi, this message translates to:
  /// **'Rất nhiều (vận động viên / lao động thể lực)'**
  String get extraActive;

  /// No description provided for @goal.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu thể trạng'**
  String get goal;

  /// No description provided for @maintainWeight.
  ///
  /// In vi, this message translates to:
  /// **'Giữ cân'**
  String get maintainWeight;

  /// No description provided for @loseWeight.
  ///
  /// In vi, this message translates to:
  /// **'Giảm cân (-500 kcal/ngày)'**
  String get loseWeight;

  /// No description provided for @gainWeight.
  ///
  /// In vi, this message translates to:
  /// **'Tăng cân (+300 kcal/ngày)'**
  String get gainWeight;

  /// No description provided for @recentFoods.
  ///
  /// In vi, this message translates to:
  /// **'Gần đây'**
  String get recentFoods;

  /// No description provided for @favoriteFoods.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get favoriteFoods;

  /// No description provided for @allFoods.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get allFoods;

  /// No description provided for @copyYesterdayMeal.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép bữa này từ hôm qua'**
  String get copyYesterdayMeal;

  /// No description provided for @copyYesterdaySuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép các món từ hôm qua'**
  String get copyYesterdaySuccess;

  /// No description provided for @noYesterdayItems.
  ///
  /// In vi, this message translates to:
  /// **'Không có món nào ở bữa này hôm qua'**
  String get noYesterdayItems;

  /// No description provided for @addCustomFood.
  ///
  /// In vi, this message translates to:
  /// **'Thêm món tùy chỉnh'**
  String get addCustomFood;

  /// No description provided for @quickAddCalories.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhanh calo'**
  String get quickAddCalories;

  /// No description provided for @foodSearchPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm món ăn (vd: pho bo, com tam)...'**
  String get foodSearchPlaceholder;

  /// No description provided for @servingSize.
  ///
  /// In vi, this message translates to:
  /// **'Khẩu phần'**
  String get servingSize;

  /// No description provided for @customFoodName.
  ///
  /// In vi, this message translates to:
  /// **'Tên món ăn'**
  String get customFoodName;

  /// No description provided for @quickAddName.
  ///
  /// In vi, this message translates to:
  /// **'Tên món / mô tả'**
  String get quickAddName;

  /// No description provided for @kcalPer100g.
  ///
  /// In vi, this message translates to:
  /// **'Calo (kcal / 100g)'**
  String get kcalPer100g;

  /// No description provided for @defaultServing.
  ///
  /// In vi, this message translates to:
  /// **'Khẩu phần mặc định (g)'**
  String get defaultServing;

  /// No description provided for @servingUnit.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị tính (bát, đĩa, cái...)'**
  String get servingUnit;

  /// No description provided for @foodAddedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm món vào nhật ký'**
  String get foodAddedSuccess;

  /// No description provided for @foodDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa món ăn'**
  String get foodDeleted;

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get editProfile;

  /// No description provided for @calorieTarget.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu calo'**
  String get calorieTarget;

  /// No description provided for @macroRatio.
  ///
  /// In vi, this message translates to:
  /// **'Tỉ lệ phân bổ macro'**
  String get macroRatio;

  /// No description provided for @units.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị đo'**
  String get units;

  /// No description provided for @metricUnit.
  ///
  /// In vi, this message translates to:
  /// **'Hệ Mét (kg, cm)'**
  String get metricUnit;

  /// No description provided for @imperialUnit.
  ///
  /// In vi, this message translates to:
  /// **'Hệ Anh-Mỹ (lb, ft/in)'**
  String get imperialUnit;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @themeMode.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @deleteAllData.
  ///
  /// In vi, this message translates to:
  /// **'Xóa toàn bộ dữ liệu'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này sẽ xóa vĩnh viễn toàn bộ nhật ký, món tùy chỉnh và hồ sơ. Bạn không thể hoàn tác.'**
  String get deleteAllDataConfirm;

  /// No description provided for @dataClearedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa toàn bộ dữ liệu'**
  String get dataClearedSuccess;

  /// No description provided for @bmrExplanation.
  ///
  /// In vi, this message translates to:
  /// **'BMR (Chỉ số trao đổi chất cơ bản): Năng lượng cơ thể tiêu thụ khi nghỉ ngơi hoàn toàn.'**
  String get bmrExplanation;

  /// No description provided for @tdeeExplanation.
  ///
  /// In vi, this message translates to:
  /// **'TDEE (Tổng năng lượng tiêu hao hằng ngày): BMR nhân với hệ số vận động.'**
  String get tdeeExplanation;

  /// No description provided for @targetExplanation.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu calo = TDEE điều chỉnh theo mục tiêu cân nặng (làm tròn đến 10 kcal).'**
  String get targetExplanation;

  /// No description provided for @formulaSummaryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ số năng lượng ước tính'**
  String get formulaSummaryTitle;

  /// No description provided for @getStarted.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu sử dụng'**
  String get getStarted;

  /// No description provided for @emptyDiary.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có món ăn nào trong ngày hôm nay'**
  String get emptyDiary;

  /// No description provided for @tapToAdd.
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào nút + để ghi món đầu tiên'**
  String get tapToAdd;

  /// No description provided for @dayView.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get dayView;

  /// No description provided for @weekView.
  ///
  /// In vi, this message translates to:
  /// **'Tuần'**
  String get weekView;

  /// No description provided for @monthView.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get monthView;

  /// No description provided for @dailyAverage.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình/ngày'**
  String get dailyAverage;

  /// No description provided for @macroAverage.
  ///
  /// In vi, this message translates to:
  /// **'Macro trung bình'**
  String get macroAverage;

  /// No description provided for @categoryAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get categoryAll;

  /// No description provided for @categoryCarb.
  ///
  /// In vi, this message translates to:
  /// **'Tinh bột'**
  String get categoryCarb;

  /// No description provided for @categoryMeat.
  ///
  /// In vi, this message translates to:
  /// **'Thịt'**
  String get categoryMeat;

  /// No description provided for @categoryFishSeafood.
  ///
  /// In vi, this message translates to:
  /// **'Cá & Hải sản'**
  String get categoryFishSeafood;

  /// No description provided for @categoryEggDairy.
  ///
  /// In vi, this message translates to:
  /// **'Trứng & Sữa'**
  String get categoryEggDairy;

  /// No description provided for @categoryVegetable.
  ///
  /// In vi, this message translates to:
  /// **'Rau củ'**
  String get categoryVegetable;

  /// No description provided for @categoryFruit.
  ///
  /// In vi, this message translates to:
  /// **'Trái cây'**
  String get categoryFruit;

  /// No description provided for @categoryDrink.
  ///
  /// In vi, this message translates to:
  /// **'Đồ uống'**
  String get categoryDrink;

  /// No description provided for @categorySnack.
  ///
  /// In vi, this message translates to:
  /// **'Ăn vặt'**
  String get categorySnack;

  /// No description provided for @categoryOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get categoryOther;

  /// No description provided for @noFoodsFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy món ăn nào phù hợp'**
  String get noFoodsFound;

  /// No description provided for @estimatedFromMacros.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính từ macro: {kcal} kcal'**
  String estimatedFromMacros(String kcal);

  /// No description provided for @servingUnitBowl.
  ///
  /// In vi, this message translates to:
  /// **'Tô / Bát'**
  String get servingUnitBowl;

  /// No description provided for @servingUnitPlate.
  ///
  /// In vi, this message translates to:
  /// **'Đĩa / Dĩa'**
  String get servingUnitPlate;

  /// No description provided for @servingUnitPiece.
  ///
  /// In vi, this message translates to:
  /// **'Cái / Chiếc / Quả'**
  String get servingUnitPiece;

  /// No description provided for @servingUnitCup.
  ///
  /// In vi, this message translates to:
  /// **'Ly / Cốc'**
  String get servingUnitCup;

  /// No description provided for @servingUnitPortion.
  ///
  /// In vi, this message translates to:
  /// **'Phần / Suất'**
  String get servingUnitPortion;

  /// No description provided for @servingUnitCan.
  ///
  /// In vi, this message translates to:
  /// **'Lon / Hộp'**
  String get servingUnitCan;

  /// No description provided for @calories.
  ///
  /// In vi, this message translates to:
  /// **'Calo'**
  String get calories;

  /// No description provided for @macros.
  ///
  /// In vi, this message translates to:
  /// **'Macro'**
  String get macros;

  /// No description provided for @unlogged.
  ///
  /// In vi, this message translates to:
  /// **'Chưa ghi'**
  String get unlogged;

  /// No description provided for @loggedDaysCount.
  ///
  /// In vi, this message translates to:
  /// **'Số ngày có ghi chép'**
  String get loggedDaysCount;

  /// No description provided for @highestDayLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày nhiều nhất'**
  String get highestDayLabel;

  /// No description provided for @lowestDayLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày ít nhất'**
  String get lowestDayLabel;

  /// No description provided for @noHistoryData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu trong khoảng thời gian này'**
  String get noHistoryData;

  /// No description provided for @generateSampleData.
  ///
  /// In vi, this message translates to:
  /// **'Tạo dữ liệu mẫu 60 ngày (Debug)'**
  String get generateSampleData;

  /// No description provided for @sampleDataGenerated.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo thành công dữ liệu mẫu 60 ngày'**
  String get sampleDataGenerated;

  /// No description provided for @macroRatioTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tỉ lệ Macro'**
  String get macroRatioTitle;

  /// No description provided for @historySummaryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tổng kết dinh dưỡng'**
  String get historySummaryTitle;

  /// No description provided for @mealsBreakdown.
  ///
  /// In vi, this message translates to:
  /// **'Phân bổ bữa ăn'**
  String get mealsBreakdown;

  /// No description provided for @chartSemantics.
  ///
  /// In vi, this message translates to:
  /// **'Biểu đồ calo và dinh dưỡng'**
  String get chartSemantics;

  /// No description provided for @profileSection.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ & Mục tiêu'**
  String get profileSection;

  /// No description provided for @editGoals.
  ///
  /// In vi, this message translates to:
  /// **'Sửa mục tiêu & Macro'**
  String get editGoals;

  /// No description provided for @editFullProfile.
  ///
  /// In vi, this message translates to:
  /// **'Sửa thông tin cá nhân'**
  String get editFullProfile;

  /// No description provided for @weightUnitLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị cân nặng'**
  String get weightUnitLabel;

  /// No description provided for @heightUnitLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị chiều cao'**
  String get heightUnitLabel;

  /// No description provided for @appearanceLanguageSection.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện & Ngôn ngữ'**
  String get appearanceLanguageSection;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dataSection.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý dữ liệu'**
  String get dataSection;

  /// No description provided for @manageFoods.
  ///
  /// In vi, this message translates to:
  /// **'Thư viện & Món tùy chỉnh'**
  String get manageFoods;

  /// No description provided for @manageFoodsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Xem món ăn, tạo và quản lý món tùy chỉnh'**
  String get manageFoodsSubtitle;

  /// No description provided for @aboutApp.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu & Phương pháp tính'**
  String get aboutApp;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản, công thức Mifflin-St Jeor, nguồn đối chiếu và lưu ý y tế'**
  String get aboutAppSubtitle;

  /// No description provided for @clearAndReset.
  ///
  /// In vi, this message translates to:
  /// **'Xóa và Đặt lại'**
  String get clearAndReset;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật hồ sơ thành công'**
  String get profileUpdatedSuccess;

  /// No description provided for @goalsUpdatedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật mục tiêu thành công'**
  String get goalsUpdatedSuccess;

  /// No description provided for @appVersionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản: 1.0.0'**
  String get appVersionLabel;

  /// No description provided for @safeFloorInfo.
  ///
  /// In vi, this message translates to:
  /// **'Mức sàn calo an toàn: Nữ tối thiểu 1200 kcal/ngày, Nam tối thiểu 1500 kcal/ngày.'**
  String get safeFloorInfo;

  /// No description provided for @medicalDisclaimerFull.
  ///
  /// In vi, this message translates to:
  /// **'CaloIn chỉ dành cho người từ 18 tuổi trở lên. Ứng dụng cung cấp ước lượng tham khảo và không thay thế tư vấn y tế, chẩn đoán hoặc điều trị từ bác sĩ hay chuyên gia dinh dưỡng.'**
  String get medicalDisclaimerFull;

  /// No description provided for @dataSourceInfo.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu dinh dưỡng được biên soạn từ Bảng thành phần thực phẩm Việt Nam (Viện Dinh Dưỡng) và USDA FoodData Central, đối chiếu kiểm tra chéo theo công thức Atwater (sai số ≤ 20%).'**
  String get dataSourceInfo;

  /// No description provided for @scanBarcode.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã vạch'**
  String get scanBarcode;

  /// No description provided for @barcodeLookupConsentTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu mã vạch trực tuyến'**
  String get barcodeLookupConsentTitle;

  /// No description provided for @barcodeLookupConsentDesc.
  ///
  /// In vi, this message translates to:
  /// **'Để tìm thông tin món ăn từ bao bì, mã vạch sẽ được gửi lên cơ sở dữ liệu mở Open Food Facts qua Internet. Bạn có muốn tiếp tục?'**
  String get barcodeLookupConsentDesc;

  /// No description provided for @cameraPermissionDeniedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quyền Camera bị từ chối'**
  String get cameraPermissionDeniedTitle;

  /// No description provided for @cameraPermissionDeniedDesc.
  ///
  /// In vi, this message translates to:
  /// **'CaloIn cần quyền sử dụng máy ảnh để quét mã vạch sản phẩm.'**
  String get cameraPermissionDeniedDesc;

  /// No description provided for @manualEntry.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tay món ăn'**
  String get manualEntry;

  /// No description provided for @scanAgain.
  ///
  /// In vi, this message translates to:
  /// **'Quét lại'**
  String get scanAgain;

  /// No description provided for @barcodeNotFoundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sản phẩm'**
  String get barcodeNotFoundTitle;

  /// No description provided for @barcodeNotFoundDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mã vạch chưa có trong dữ liệu Open Food Facts. Bạn có thể tự nhập thông tin món ăn này.'**
  String get barcodeNotFoundDesc;

  /// No description provided for @networkErrorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng'**
  String get networkErrorTitle;

  /// No description provided for @networkErrorDesc.
  ///
  /// In vi, this message translates to:
  /// **'Không thể kết nối Internet để tra cứu. Vui lòng kiểm tra mạng hoặc nhập tay món ăn.'**
  String get networkErrorDesc;

  /// No description provided for @timeoutTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hết thời gian chờ'**
  String get timeoutTitle;

  /// No description provided for @timeoutDesc.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu tra cứu quá thời gian (10 giây). Vui lòng thử lại hoặc nhập tay.'**
  String get timeoutDesc;

  /// No description provided for @incompleteNutritionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu số liệu dinh dưỡng'**
  String get incompleteNutritionTitle;

  /// No description provided for @incompleteNutritionDesc.
  ///
  /// In vi, this message translates to:
  /// **'Sản phẩm đã tìm thấy nhưng chưa đủ số liệu calo/macro trên Open Food Facts. Vui lòng bổ sung.'**
  String get incompleteNutritionDesc;

  /// No description provided for @viewfinderHint.
  ///
  /// In vi, this message translates to:
  /// **'Di chuyển mã vạch vào khung ngắm'**
  String get viewfinderHint;

  /// No description provided for @searchingBarcode.
  ///
  /// In vi, this message translates to:
  /// **'Đang tra cứu Open Food Facts...'**
  String get searchingBarcode;

  /// No description provided for @openFoodFactsAttribution.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu tra cứu mã vạch từ Open Food Facts (ODbL).'**
  String get openFoodFactsAttribution;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
