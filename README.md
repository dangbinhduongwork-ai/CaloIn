# CaloIn - Ứng dụng Ghi Nhật Ký & Theo Dõi Calo Nạp Vào

CaloIn là ứng dụng di động Flutter chuyên biệt theo dõi năng lượng nạp vào (**Calories In**) và các dưỡng chất đa lượng (**Macro**: protein, carb, fat) mỗi ngày. Ứng dụng hoạt động **hoàn toàn offline**, lưu trữ dữ liệu cục bộ bảo mật trên thiết bị, giao diện Material 3 hiện đại, hỗ trợ song ngữ Tiếng Việt và English.

---

## Ảnh Chụp Màn Hình (Screenshots)

| Hôm nay (Dashboard) | Thư viện Món ăn | Lịch sử (fl_chart) | Cài đặt |
| :---: | :---: | :---: | :---: |
| *(Chỗ trống ảnh màn hình Hôm nay)* | *(Chỗ trống ảnh Thư viện món ăn)* | *(Chỗ trống ảnh Biểu đồ lịch sử)* | *(Chỗ trống ảnh Cài đặt)* |

---

## Yêu Cầu Môi Trường & Cài Đặt

- **Flutter SDK**: `>= 3.3.0` (Khuyến nghị Flutter 3.19.x hoặc mới nhất)
- **Dart SDK**: `>= 3.3.0 < 4.0.0`
- **Hệ điều hành hỗ trợ**: Android (API level 21 trở lên), iOS (iOS 12.0 trở lên)
- **Công cụ phát triển**: Android Studio, VS Code hoặc Antigravity IDE

---

## Hướng Dẫn Chạy Dự Án

1. **Cài đặt thư viện dependencies:**
   ```bash
   flutter pub get
   ```

2. **Chạy ứng dụng trong môi trường phát triển:**
   ```bash
   flutter run
   ```

3. **Chạy kiểm thử tự động (Unit & Widget Tests):**
   ```bash
   flutter test
   ```

4. **Chạy Integration Tests (End-to-End):**
   ```bash
   flutter test integration_test/app_flow_test.dart
   ```

5. **Kiểm tra cú pháp và chất lượng mã nguồn:**
   ```bash
   flutter analyze
   ```

6. **Đóng gói bản cài đặt Android Release:**
   ```bash
   flutter build apk --release
   ```

---

## Lệnh Sinh Mã Nguồn (Code Generation)

Dự án sử dụng Drift ORM cho cơ sở dữ liệu SQLite. File `app_database.g.dart` đã được cấu hình sẵn. Khi cập nhật bảng dữ liệu trong `lib/core/database/app_database.dart`, chạy lệnh sau để sinh lại mã nguồn:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Cấu Trúc Thư Mục Dự Án

```
lib/
├── core/                               # Các thành phần dùng chung toàn app
│   ├── constants/                      # Hằng số (AppConstants)
│   ├── database/                       # Drift SQLite (AppDatabase, tables)
│   ├── localization/                   # Quản lý LocaleProvider
│   ├── router/                         # GoRouter (app_router, bottom navigation)
│   ├── theme/                          # AppColors, AppTheme, ThemeProvider
│   └── utils/                          # Bộ chuyển đổi đơn vị, chuẩn hóa tiếng Việt
├── features/                           # Kiến trúc Feature-driven
│   ├── dashboard/                      # Tab Hôm nay: vòng tiến độ, thanh macro, bữa ăn
│   ├── diary/                          # Ghi món, sửa, xóa, sao chép bữa, quick-add
│   ├── foods/                          # Thư viện món ăn, tìm kiếm không dấu, món tùy chỉnh
│   ├── history/                        # Tab Lịch sử: fl_chart tuần/tháng, pure-Dart aggregator
│   ├── profile/                        # Onboarding 4 bước, BMR/TDEE, mục tiêu calo, macro
│   └── settings/                       # Tab Cài đặt: hồ sơ, đơn vị, ngôn ngữ, theme, xóa data
├── l10n/                               # Đa ngôn ngữ (.arb, AppLocalizations)
└── main.dart                           # Entrypoint khởi tạo SharedPreferences, ProviderScope
```

---

## Tech Stack & Thư Viện Cốt Lõi

1. **`flutter_riverpod: ^2.5.1`**: Quản lý trạng thái và Dependency Injection hiện đại, không phụ thuộc BuildContext.
2. **`go_router: ^14.2.0`**: Điều hướng phân cấp với `StatefulShellRoute.indexedStack` cho thanh điều hướng 3 tab chính (giữ trạng thái từng tab).
3. **`drift: ^2.18.0`**: ORM tĩnh kiểu type-safe cho SQLite trong Dart với reactive stream query (`watch()`).
4. **`sqlite3_flutter_libs: ^0.5.24`**: Binary SQLite C native nhúng sẵn cho Android/iOS.
5. **`fl_chart: ^0.68.0`**: Biểu đồ cột phân tích calo và thanh xếp chồng macro (Protein/Carb/Fat).
6. **`shared_preferences: ^2.2.3`**: Lưu trữ cục bộ hồ sơ cá nhân, cài đặt đơn vị, theme và locale.
7. **`intl: ^0.19.0`**: Định dạng ngày tháng, số liệu theo bản địa hóa.
8. **`mobile_scanner: ^5.2.3`**: Quét mã vạch sản phẩm đóng gói qua máy ảnh (EAN-13, UPC, Code 128,...).
9. **`http: ^1.2.1`**: Tra cứu dữ liệu dinh dưỡng sản phẩm từ Open Food Facts qua kết nối mạng.

---

## Công Thức Dinh Dưỡng & Giả Định Tính Toán

### 1. Công thức BMR (Mifflin-St Jeor)
- **Nam**:
  $$\text{BMR} = 10 \times \text{Cân nặng (kg)} + 6.25 \times \text{Chiều cao (cm)} - 5 \times \text{Tuổi} + 5$$
- **Nữ**:
  $$\text{BMR} = 10 \times \text{Cân nặng (kg)} + 6.25 \times \text{Chiều cao (cm)} - 5 \times \text{Tuổi} - 161$$

### 2. Tổng tiêu hao năng lượng hằng ngày (TDEE)
$$\text{TDEE} = \text{BMR} \times \text{Hệ số vận động}$$
- Ít vận động (Sedentary): `1.2`
- Vận động nhẹ (Light): `1.375`
- Vận động vừa (Moderate): `1.55`
- Vận động nhiều (Very Active): `1.725`
- Rất nhiều (Extra Active): `1.9`

### 3. Mục tiêu Calo hằng ngày (Daily Goal)
- **Giữ cân**: $\text{Target} = \text{TDEE}$
- **Giảm cân**: $\text{Target} = \text{TDEE} - 500\text{ kcal/ngày}$
- **Tăng cân**: $\text{Target} = \text{TDEE} + 300\text{ kcal/ngày}$
- Kết quả được làm tròn đến $10\text{ kcal}$ gần nhất.

### 4. Mức sàn calo an toàn (Safe Calorie Floors)
- **Nữ**: Tối thiểu **1,200 kcal/ngày**
- **Nam**: Tối thiểu **1,500 kcal/ngày**
- Khi tính toán hoặc nhập thủ công dưới mức sàn, hệ thống hiển thị cảnh báo y tế rõ ràng.

### 5. Khung giờ gợi ý bữa ăn mặc định
- **05:00 – 10:00**: Bữa sáng (`MealType.breakfast`)
- **10:00 – 14:00**: Bữa trưa (`MealType.lunch`)
- **14:00 – 17:00**: Bữa phụ chiều (`MealType.snack`)
- **17:00 – 22:00**: Bữa tối (`MealType.dinner`)
- **Các giờ khác**: Bữa phụ (`MealType.snack`)

### 6. Giả định Lịch sử & Mục tiêu
- **Mục tiêu calo quá khứ**: So sánh trực tiếp với mục tiêu calo hiện tại của hồ sơ (không lưu biến động mục tiêu theo từng ngày).
- **Tính toán trung bình**: Ngày không ghi chép **KHÔNG** bị tính là 0 kcal; trung bình chỉ tính trên các ngày thực sự có bản ghi ($$\text{Trung bình} = \frac{\sum \text{Dinh dưỡng ngày có ghi}}{\text{Số ngày có ghi}}$$).
- **Quy ước lịch tuần**: Luôn bắt đầu từ **thứ Hai** (Monday) và kết thúc vào **Chủ Nhật** (Sunday).
- **Trải nghiệm không phán xét (Non-judgmental UX)**: Không tô đỏ cảnh báo hoảng loạn khi vượt calo; dùng màu trung tính `#0D9488` (Emerald Mint) hoặc hổ phách ấm `#D97706`.

---

## Dữ Liệu Món Ăn, Nâng Cấp Seed & Kiểm Tra Atwater

### 1. Trạng thái dữ liệu "Estimated"
- 89 món ăn phổ biến ban đầu được lưu tại `assets/data/foods_seed.json` với trạng thái `dataQuality: estimated`.
- Dữ liệu được tổng hợp từ Bảng thành phần thực phẩm Việt Nam (Viện Dinh Dưỡng Quốc Gia) và USDA FoodData Central.
- Mọi món ăn được kiểm tra chéo tự động theo phương trình Atwater:
  $$\text{kcal} \approx \text{protein} \times 4 + \text{carb} \times 4 + \text{fat} \times 9 \quad (\text{sai số} \le 20\%)$$
- Chi tiết các món cần rà soát thêm được ghi nhận trong `docs/FOOD_DATA_TODO.md`.

### 2. Quy trình Cập nhật Dữ liệu Món ăn & Tăng SeedVersion
Khi cần bổ sung hoặc cập nhật danh sách món ăn hạt giống:
1. Chỉnh sửa file `assets/data/foods_seed.json`.
2. Mở `lib/core/constants/app_constants.dart` và tăng hằng số `currentSeedVersion` (ví dụ từ `1` lên `2`).
3. Khi người dùng mở app, phương thức `initializeFoodsSeed()` sẽ tự động chạy cơ chế **upsert**:
   - Cập nhật thông tin calo, macro, tên món của các món seed dựa theo `seedKey`.
   - Giữ nguyên trạng thái yêu thích (`isFavorite`) của người dùng.
   - Tuyệt đối không xóa hay ảnh hưởng đến các món tùy chỉnh (`isCustom == true`) của người dùng.

---

## Tra Cứu Mã Vạch & Open Food Facts (ODbL)

- **Quét mã vạch**: Hỗ trợ quét mã vạch sản phẩm đóng gói (EAN-13, EAN-8, UPC-A, UPC-E, Code 128...) bằng camera qua thư viện `mobile_scanner`.
- **Nguồn dữ liệu mở Open Food Facts**:
  - Tra cứu trực tuyến thông tin dinh dưỡng từ Open Food Facts API v2 (`https://world.openfoodfacts.org/api/v2/product/{barcode}.json`).
  - **Quy chuẩn API**: Tuân thủ yêu cầu bắt buộc của Open Food Facts với custom `User-Agent`: `CaloIn - Flutter - Version 1.0.0 - https://github.com/dangbinhduongwork-ai/CaloIn`.
  - **Bảo vệ quyền riêng tư**: Hộp thoại hỏi ý kiến (Consent Dialog) hiển thị trước lần quét đầu tiên để người dùng xác nhận việc gửi mã vạch qua kết nối Internet.
  - **Quy trình lưu trữ**: Sản phẩm tìm thấy được mở trong màn hình chỉnh sửa món tùy chỉnh để người dùng xem lại, hiệu chỉnh số liệu khẩu phần thực tế, sau đó lưu vào SQLite cục bộ (`isCustom: true`, `dataQuality: 'community'`). Sau khi lưu, món ăn hoàn toàn có thể sử dụng và tìm kiếm offline.
  - **Giấy phép ODbL**: Dữ liệu dinh dưỡng sản phẩm từ Open Food Facts được cấp phép theo [Open Database License (ODbL)](https://opendatacommons.org/licenses/odbl/).

---

## Giới Hạn Đã Biết (Known Limitations)

1. **Phạm vi Calo**: Ứng dụng chỉ theo dõi lượng calo **nạp vào** (Calories In) và các dưỡng chất đa lượng; không theo dõi lượng calo tiêu hao khi luyện tập thể thao (tính năng thuộc ứng dụng CaloOut riêng).
2. **Lưu trữ Cục bộ (Offline-first)**: Toàn bộ dữ liệu nhật ký và món ăn lưu trên máy (SQLite & SharedPreferences), không có tài khoản và không đồng bộ đám mây (cloud sync) giữa nhiều thiết bị. Quét mã vạch là tính năng duy nhất cần kết nối Internet tạm thời để tra cứu thông tin ban đầu.

