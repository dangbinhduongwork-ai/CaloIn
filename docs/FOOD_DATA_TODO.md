# DANH SÁCH MÓN ĂN CẦN KIỂM TRA ĐỐI CHIẾU NGUỒN DINH DƯỠNG (FOOD DATA TODO)

> **Ghi chú quan trọng**:
> Toàn bộ dữ liệu trong `assets/data/foods_seed.json` hiện đang mang trạng thái `dataQuality: "estimated"`.
> Cần đối chiếu với:
> 1. **Bảng thành phần thực phẩm Việt Nam** (Viện Dinh dưỡng Quốc gia - Bộ Y tế).
> 2. **USDA FoodData Central** (đối với các nguyên liệu cơ bản, thịt cá tươi sống, hoa quả và đồ uống công nghiệp).

---

## 1. Món ăn truyền thống nhiều nguyên liệu phức tạp (Cần kiểm tra công thức chuẩn)
- [ ] **Bún chả Hà Nội (`bun_cha`)**: Cần tách rõ tỉ lệ thịt nướng (chả miếng/chả băm), lượng mỡ ngấm vào nước chấm pha đường giấm.
- [ ] **Cơm tấm sườn bì chả (`com_tam_suon`)**: Sườn nướng có quét mỡ hành/mật ong, chả trứng hấp, bì heo trộn thính gạo.
- [ ] **Bánh xèo (`banh_xeo`)**: Lượng dầu chiên ngấm vào vỏ bánh và thành phần nhân (thịt ba chỉ, tôm, giá đỗ).
- [ ] **Bánh mì kẹp thịt pate (`banh_mi_thit`)**: Hàm lượng chất béo từ pate gan, bơ trứng (mayonnaise Việt Nam) và thịt xá xíu/giò.
- [ ] **Bún đậu mắm tôm (`bun_dau_mam_tom`)**: Chưa tính dầu rán đậu và lượng đường/dầu sôi pha vào mắm tôm.
- [ ] **Bánh cuốn thịt (`banh_cuon`)**: Lượng dầu xoa chống dính và nhân mộc nhĩ xào thịt nạc vai.
- [ ] **Gỏi cuốn tôm thịt (`goi_cuon`)**: Chưa bao gồm năng lượng từ sốt tương đen đậu phộng hoặc mắm nêm kèm theo.
- [ ] **Bánh tráng trộn (`banh_trang_tron`)**: Biến thiên rất lớn tùy theo lượng dầu sa tế, muối tôm, khô bò và đậu phộng rang.

## 2. Nước dùng & Canh súp (Broths & Soups)
- [ ] **Phở bò (`pho_bo`) & Phở gà (`pho_ga`)**: Phụ thuộc độ ngậy của nước dùng (có váng mỡ gầu hay nước trong thanh).
- [ ] **Bún bò Huế (`bun_bo_hue`)**: Mức ớt màu sa tế và mỡ nổi trên bề mặt tô.
- [ ] **Canh chua cá lóc (`canh_chua_ca_loc`)**: Độ ngọt từ đường nêm nếm đặc trưng miền Nam.

## 3. Đồ uống pha chế (Beverages)
- [ ] **Cà phê sữa đá (`ca_phe_sua_da`)**: Lượng sữa đặc có đường dao động từ 20ml đến 40ml tùy quán.
- [ ] **Trà sữa trân châu (`tra_sua_tran_chau`)**: Hàm lượng đường tổng và lượng calo từ bột kem béo thực vật (non-dairy creamer) cùng trân châu đen.
- [ ] **Sinh tố bơ (`sinh_to_bo`)**: Tỉ lệ bơ, sữa đặc và sữa tươi.

## 4. Thực phẩm đóng gói / Chế biến sẵn
- [ ] **Xúc xích heo (`xuc_xich_heo`)**: Khác biệt theo từng nhãn hàng (Vissan, CP, Đức Việt...).
- [ ] **Chả lụa / Giò lụa (`cha_lua`)**: Tỉ lệ nạc/mỡ pha khi giã giò.

---
*File này được sinh tự động bởi hệ thống CaloIn để phục vụ công tác rà soát số liệu thực tế.*
