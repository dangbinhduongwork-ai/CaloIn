# CaloIn - Ứng dụng Ghi nhật ký & Theo dõi Calo nạp vào

CaloIn là ứng dụng Flutter theo dõi calo nạp vào (Calories In) và các dưỡng chất đa lượng (protein, carb, fat) mỗi ngày, hoạt động hoàn toàn offline, lưu trữ dữ liệu cục bộ, giao diện Material 3 hỗ trợ Tiếng Việt và English.

---

## Tech Stack & Thư viện Cốt lõi

1. **`drift: ^2.18.0`**: Lớp ORM/Query builder kiểu tĩnh (type-safe) cho SQLite trong Dart. Giúp quản lý schema, quan hệ bảng, streaming reactive queries (`watch()`) và di chuyển cơ sở dữ liệu (migration).
2. **`drift_dev: ^2.18.0`**: Code generator tạo mã nguồn tự động cho Drift tables, classes mapping, và update companions.
3. **`build_runner: ^2.4.9`**: Công cụ chạy build step sinh code chuẩn của hệ sinh thái Dart/Flutter.
4. **`sqlite3_flutter_libs: ^0.5.24`**: Cung cấp binary SQLite C native mới nhất được đóng gói sẵn cho Android, iOS, Windows, macOS, Linux, đảm bảo hiệu năng và tính tương thích nền tảng cao nhất.
5. **`flutter_riverpod: ^2.5.1`**: Quản lý trạng thái và Dependency Injection hiện đại, không phụ thuộc BuildContext.
6. **`go_router: ^14.2.0`**: Điều hướng phân cấp với `StatefulShellRoute` cho thanh điều hướng 4 tab.
7. **`fl_chart: ^0.68.0`**: Biểu đồ phân tích calo và xu hướng theo thời gian.
8. **`shared_preferences: ^2.2.3`**: Lưu trữ cục bộ các cài đặt nhẹ (hồ sơ, theme, ngôn ngữ, phiên bản seed).

---

## Lệnh sinh mã nguồn (Code Generation)

Khi cập nhật cấu trúc bảng trong `lib/core/database/app_database.dart`, chạy lệnh sau trong terminal:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Cấu trúc Cơ sở dữ liệu SQLite (Drift)

- **Bảng `foods`**:
  - `id`: Khóa chính tự tăng (Integer).
  - `seed_key`: Định danh ổn định của món seed (Nullable, Unique), phục vụ việc nâng cấp seed không ghi đè dữ liệu người dùng.
  - `name_vi`, `name_en`: Tên tiếng Việt và tiếng Anh.
  - `search_key`: Chuỗi chuẩn hóa không dấu dùng cho tìm kiếm tiếng Việt tốc độ cao.
  - `kcal_per100g`, `protein_per100g`, `carb_per100g`, `fat_per100g`: Dinh dưỡng trên 100g.
  - `default_serving_grams`, `serving_label_key`: Khẩu phần mặc định và nhãn (bát, đĩa, cái, ly...).
  - `category`: Nhóm thực phẩm (`carb`, `meat`, `fish_seafood`, `egg_dairy`, `vegetable`, `fruit`, `drink`, `snack`, `other`).
  - `is_custom`: Đánh dấu món do người dùng tự tạo.
  - `is_favorite`: Đánh dấu món yêu thích.
  - `data_quality`: Trạng thái kiểm chứng dữ liệu (`estimated` hoặc `custom`).

- **Bảng `food_logs`**:
  - `id`: Khóa chính chuỗi GUID/UUID.
  - `food_id`: Mã món ăn (Nullable, không ràng buộc cứng để khi xóa món tùy chỉnh không mất nhật ký).
  - `food_name_snapshot`: Tên món chụp lại tại thời điểm ghi.
  - `meal_type`: Bữa ăn (`breakfast`, `lunch`, `dinner`, `snack`).
  - `grams`: Khối lượng tiêu thụ (Nullable khi là Thêm nhanh calo).
  - `kcal`, `protein`, `carb`, `fat`: Snapshot dinh dưỡng tính tại thời điểm ăn.
  - `is_quick_add`: Đánh dấu mục thêm nhanh calo.
  - `logged_at`: Thời điểm ghi nhật ký (Đã đánh chỉ mục `idx_food_logs_logged_at`).

---

## Dữ liệu hạt giống & Kiểm tra Atwater

- Dữ liệu 89 món ăn phổ biến được lưu tại `assets/data/foods_seed.json`.
- Tất cả các món ăn được kiểm tra chéo tự động bằng phương trình Atwater:
  $$\text{kcal} \approx \text{protein} \times 4 + \text{carb} \times 4 + \text{fat} \times 9$$
- Sai số tối đa cho phép là $20\%$ đối với các món ăn thông thường (các món đặc thù như rượu/cà phê đen/trà có cờ `atwaterCheckExempt: true`).
- Chi tiết các món cần rà soát thêm có trong `docs/FOOD_DATA_TODO.md`.
