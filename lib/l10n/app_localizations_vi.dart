// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'CaloIn';

  @override
  String get disclaimer =>
      'Kết quả chỉ mang tính ước lượng, không thay thế tư vấn y tế hoặc dinh dưỡng.';

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
  String get under18Warning =>
      'Ứng dụng chỉ dành cho người từ 18 tuổi trở lên. Nhu cầu dinh dưỡng ở độ tuổi dưới 18 đang phát triển và cần được tư vấn bởi bác sĩ hoặc phụ huynh.';

  @override
  String floorWarning(int calories) {
    return 'Mức calo tính toán đã được nâng lên mức sàn an toàn ($calories kcal) để đảm bảo năng lượng tối thiểu cho cơ thể.';
  }

  @override
  String manualFloorWarning(int calories, int floor) {
    return 'Mức calo bạn nhập ($calories kcal) thấp hơn mức sàn an toàn ($floor kcal/ngày). Cắt giảm calo quá thấp có thể gây suy nhược và ảnh hưởng sức khỏe. Bạn có chắc chắn muốn tiếp tục?';
  }

  @override
  String exceedCalories(int calories) {
    return 'Đã nạp hơn $calories kcal so với mục tiêu';
  }

  @override
  String remainingCalories(int calories) {
    return 'Còn lại $calories kcal';
  }

  @override
  String targetCalories(int calories) {
    return 'Mục tiêu: $calories kcal';
  }

  @override
  String consumedCalories(int calories) {
    return 'Đã nạp: $calories kcal';
  }

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
  String get deleteAllDataConfirm =>
      'Hành động này sẽ xóa vĩnh viễn toàn bộ nhật ký, món tùy chỉnh và hồ sơ. Bạn không thể hoàn tác.';

  @override
  String get dataClearedSuccess => 'Đã xóa toàn bộ dữ liệu';

  @override
  String get bmrExplanation =>
      'BMR (Chỉ số trao đổi chất cơ bản): Năng lượng cơ thể tiêu thụ khi nghỉ ngơi hoàn toàn.';

  @override
  String get tdeeExplanation =>
      'TDEE (Tổng năng lượng tiêu hao hằng ngày): BMR nhân với hệ số vận động.';

  @override
  String get targetExplanation =>
      'Mục tiêu calo = TDEE điều chỉnh theo mục tiêu cân nặng (làm tròn đến 10 kcal).';

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
  String estimatedFromMacros(String kcal) {
    return 'Ước tính từ macro: $kcal kcal';
  }

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

  @override
  String get calories => 'Calo';

  @override
  String get macros => 'Macro';

  @override
  String get unlogged => 'Chưa ghi';

  @override
  String get loggedDaysCount => 'Số ngày có ghi chép';

  @override
  String get highestDayLabel => 'Ngày nhiều nhất';

  @override
  String get lowestDayLabel => 'Ngày ít nhất';

  @override
  String get noHistoryData => 'Không có dữ liệu trong khoảng thời gian này';

  @override
  String get generateSampleData => 'Tạo dữ liệu mẫu 60 ngày (Debug)';

  @override
  String get sampleDataGenerated => 'Đã tạo thành công dữ liệu mẫu 60 ngày';

  @override
  String get macroRatioTitle => 'Tỉ lệ Macro';

  @override
  String get historySummaryTitle => 'Tổng kết dinh dưỡng';

  @override
  String get mealsBreakdown => 'Phân bổ bữa ăn';

  @override
  String get chartSemantics => 'Biểu đồ calo và dinh dưỡng';

  @override
  String get profileSection => 'Hồ sơ & Mục tiêu';

  @override
  String get editGoals => 'Sửa mục tiêu & Macro';

  @override
  String get editFullProfile => 'Sửa thông tin cá nhân';

  @override
  String get weightUnitLabel => 'Đơn vị cân nặng';

  @override
  String get heightUnitLabel => 'Đơn vị chiều cao';

  @override
  String get appearanceLanguageSection => 'Giao diện & Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get dataSection => 'Quản lý dữ liệu';

  @override
  String get manageFoods => 'Thư viện & Món tùy chỉnh';

  @override
  String get manageFoodsSubtitle => 'Xem món ăn, tạo và quản lý món tùy chỉnh';

  @override
  String get aboutApp => 'Giới thiệu & Phương pháp tính';

  @override
  String get aboutAppSubtitle =>
      'Phiên bản, công thức Mifflin-St Jeor, nguồn đối chiếu và lưu ý y tế';

  @override
  String get clearAndReset => 'Xóa và Đặt lại';

  @override
  String get profileUpdatedSuccess => 'Đã cập nhật hồ sơ thành công';

  @override
  String get goalsUpdatedSuccess => 'Đã cập nhật mục tiêu thành công';

  @override
  String get appVersionLabel => 'Phiên bản: 1.0.0';

  @override
  String get safeFloorInfo =>
      'Mức sàn calo an toàn: Nữ tối thiểu 1200 kcal/ngày, Nam tối thiểu 1500 kcal/ngày.';

  @override
  String get medicalDisclaimerFull =>
      'CaloIn chỉ dành cho người từ 18 tuổi trở lên. Ứng dụng cung cấp ước lượng tham khảo và không thay thế tư vấn y tế, chẩn đoán hoặc điều trị từ bác sĩ hay chuyên gia dinh dưỡng.';

  @override
  String get dataSourceInfo =>
      'Dữ liệu dinh dưỡng được biên soạn từ Bảng thành phần thực phẩm Việt Nam (Viện Dinh Dưỡng) và USDA FoodData Central, đối chiếu kiểm tra chéo theo công thức Atwater (sai số ≤ 20%).';

  @override
  String get scanBarcode => 'Quét mã vạch';

  @override
  String get barcodeLookupConsentTitle => 'Tra cứu mã vạch trực tuyến';

  @override
  String get barcodeLookupConsentDesc =>
      'Để tìm thông tin món ăn từ bao bì, mã vạch sẽ được gửi lên cơ sở dữ liệu mở Open Food Facts qua Internet. Bạn có muốn tiếp tục?';

  @override
  String get cameraPermissionDeniedTitle => 'Quyền Camera bị từ chối';

  @override
  String get cameraPermissionDeniedDesc =>
      'CaloIn cần quyền sử dụng máy ảnh để quét mã vạch sản phẩm.';

  @override
  String get manualEntry => 'Nhập tay món ăn';

  @override
  String get scanAgain => 'Quét lại';

  @override
  String get barcodeNotFoundTitle => 'Không tìm thấy sản phẩm';

  @override
  String get barcodeNotFoundDesc =>
      'Mã vạch chưa có trong dữ liệu Open Food Facts. Bạn có thể tự nhập thông tin món ăn này.';

  @override
  String get networkErrorTitle => 'Không có kết nối mạng';

  @override
  String get networkErrorDesc =>
      'Không thể kết nối Internet để tra cứu. Vui lòng kiểm tra mạng hoặc nhập tay món ăn.';

  @override
  String get timeoutTitle => 'Hết thời gian chờ';

  @override
  String get timeoutDesc =>
      'Yêu cầu tra cứu quá thời gian (10 giây). Vui lòng thử lại hoặc nhập tay.';

  @override
  String get incompleteNutritionTitle => 'Thiếu số liệu dinh dưỡng';

  @override
  String get incompleteNutritionDesc =>
      'Sản phẩm đã tìm thấy nhưng chưa đủ số liệu calo/macro trên Open Food Facts. Vui lòng bổ sung.';

  @override
  String get viewfinderHint => 'Di chuyển mã vạch vào khung ngắm';

  @override
  String get searchingBarcode => 'Đang tra cứu Open Food Facts...';

  @override
  String get openFoodFactsAttribution =>
      'Dữ liệu tra cứu mã vạch từ Open Food Facts (ODbL).';
}
