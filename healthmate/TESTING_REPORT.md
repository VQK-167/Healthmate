# BÁO CÁO KIỂM THỬ VÀ KIỂM ĐỊNH ỨNG DỤNG HEALTHMATE

## 1. Thông tin chung

- **Tên ứng dụng:** HealthMate
- **Nền tảng phát triển:** Flutter/Dart
- **Phạm vi kiểm thử:** Logic nghiệp vụ, model, repository/store, validation form, giao diện Nutrition và kiểm tra chất lượng mã nguồn.
- **Công cụ sử dụng:** Flutter Test, Flutter Analyzer, Widget Test và kiểm thử thủ công trên môi trường phát triển.
- **Môi trường kiểm tra:** Windows, Chrome/Edge.

## 2. Mục tiêu kiểm thử

Việc kiểm thử nhằm xác định các chức năng chính của HealthMate hoạt động đúng theo yêu cầu, phát hiện lỗi nhập liệu và lỗi trạng thái, đồng thời kiểm tra khả năng ứng dụng xử lý dữ liệu thiếu hoặc không hợp lệ.

Các mục tiêu chính gồm:

1. Kiểm tra các hàm tính toán sức khỏe và mục tiêu.
2. Kiểm tra model dữ liệu có thể chuyển đổi qua lại chính xác.
3. Kiểm tra thêm, sửa, xóa dữ liệu dinh dưỡng và buổi tập.
4. Kiểm tra validation đối với dữ liệu người dùng nhập vào.
5. Kiểm tra các trạng thái chưa có dữ liệu và lỗi từ Firebase/Firestore.
6. Kiểm tra giao diện và điều hướng chính của ứng dụng.

---

# Câu 8 — Kiểm thử và kiểm định

## 8a. Bắt lỗi và xử lý lỗi

Ứng dụng có các cơ chế kiểm tra và xử lý các nhóm lỗi sau:

### a. Lỗi dữ liệu nhập vào

- Bỏ trống tên món ăn.
- Nhập calo không phải số.
- Nhập khẩu phần bằng 0 hoặc số âm.
- Nhập lượng nước không hợp lệ.
- Nhập cân nặng không hợp lệ.
- Nhập thời lượng tập bằng 0, số âm hoặc sai định dạng.
- Nhập các giá trị mục tiêu không phù hợp.

Các lỗi này được kiểm tra trước khi lưu. Form giữ nguyên trên màn hình và hiển thị thông báo để người dùng sửa lại dữ liệu.

### b. Lỗi xác thực người dùng

- Người dùng chưa đăng nhập.
- Phiên đăng nhập hết hạn hoặc không còn hợp lệ.
- Không lấy được thông tin hồ sơ người dùng.

Ứng dụng không tiếp tục thao tác ghi dữ liệu khi không xác định được người dùng hợp lệ.

### c. Lỗi Firebase/Firestore

- Không có quyền đọc hoặc ghi dữ liệu.
- Dữ liệu từ Firestore bị thiếu hoặc có giá trị `null`.
- Mất kết nối mạng hoặc thao tác ghi dữ liệu bị lỗi.
- Stream dữ liệu không trả về kết quả.

Ứng dụng sử dụng trạng thái loading, trạng thái không có dữ liệu và thông báo lỗi bằng SnackBar/dialog thay vì để ứng dụng bị crash.

### d. Lỗi thao tác người dùng

- Người dùng đóng dialog.
- Người dùng hủy thao tác thêm hoặc sửa.
- Người dùng rời khỏi màn hình trước khi lưu.

Trong các trường hợp này, dữ liệu cũ được giữ nguyên và không tạo bản ghi không hoàn chỉnh.

### e. Các biện pháp đã áp dụng

- Sử dụng validator cho các trường nhập liệu.
- Kiểm tra giá trị `null` trước khi hiển thị dữ liệu.
- Dùng `try/catch` khi thao tác với Firebase.
- Hiển thị trạng thái loading và empty state.
- Hiển thị SnackBar để thông báo thao tác thành công hoặc thất bại.
- Không gọi `pumpAndSettle()` vô hạn trong widget test có `StreamBuilder` liên tục; thay bằng thời gian chờ giới hạn.

---

## 8b. Unit test và Widget test

Các nhóm kiểm thử được triển khai trong thư mục `test/`:

| STT | Nhóm chức năng | File kiểm thử |
|---:|---|---|
| 1 | Model sức khỏe và dữ liệu chỉ số | `health_metric_test.dart` |
| 2 | BMI, huyết áp, nhịp tim và cảnh báo bất thường | `health_rules_test.dart` |
| 3 | Mục tiêu, tiến độ, calo MET và chuỗi ngày tập | `goal_rules_test.dart` |
| 4 | Model món ăn/dinh dưỡng | `nutrition_model_test.dart` |
| 5 | Hàm hỗ trợ Nutrition | `nutrition_helpers_test.dart` |
| 6 | Danh sách món ăn mẫu | `nutrition_preset_test.dart` |
| 7 | In-memory nutrition store | `nutrition_store_test.dart` |
| 8 | Form thêm/sửa món ăn | `nutrition_add_meal_page_test.dart` |
| 9 | Giao diện Nutrition | `nutrition_page_test.dart` |
| 10 | Model buổi tập | `workout_model_test.dart` |
| 11 | Model hồ sơ người dùng và mục tiêu | `user_model_test.dart` |

### Nội dung đã kiểm thử

- Chuyển đổi model qua lại giữa object và Map.
- Hàm `copyWith` chỉ thay đổi các trường được yêu cầu.
- Tính BMI theo cân nặng và chiều cao.
- Phân loại BMI theo các ngưỡng WHO.
- Phân loại huyết áp và nhịp tim.
- Phát hiện chỉ số sức khỏe bất thường.
- Tính calo tiêu hao dựa trên MET.
- Tính tiến độ mục tiêu không vượt quá 100%.
- Tính chuỗi ngày tập liên tiếp.
- Tìm món ăn có dấu và không dấu.
- Lọc món ăn theo nhóm.
- Từ chối tên món rỗng, calo sai định dạng và khẩu phần bằng 0.
- Thêm món hợp lệ và trả về đối tượng `Meal`.
- Sửa món nhưng giữ nguyên ID và thời gian ăn.
- Cộng thêm 250 ml nước.
- Hiển thị món ăn và tổng calo trong ngày.
- Vuốt để xóa món ăn.
- Chuyển ngày và kiểm tra dữ liệu của từng ngày.
- Mở chi tiết món ăn với nút Sửa và Xóa.

---

## 8c. Kiểm thử toàn bộ ứng dụng

### Lệnh đã sử dụng

Chạy tại thư mục `healthmate/`:

```bash
flutter analyze
flutter test
```

### Kết quả `flutter analyze`

```text
No issues found! (ran in 1.5s)
```

Kết luận: mã nguồn không còn lỗi analyzer hoặc cảnh báo lint tại thời điểm kiểm tra.

### Kết quả `flutter test`

```text
93 tests passed!
```

| Kết quả | Số lượng |
|---|---:|
| Tổng số test | 93 |
| Thành công | 93 |
| Thất bại | 0 |
| Tỷ lệ thành công | 100% |

Các test đã bao gồm kiểm thử logic, model, store, validation form, Add Meal và giao diện Nutrition.

### Vấn đề đã phát hiện và khắc phục trong quá trình kiểm thử

1. **Nutrition test bị chờ quá lâu:** nguyên nhân là `pumpAndSettle()` chờ các `StreamBuilder` liên tục ổn định. Đã thay bằng `pump` với thời gian giới hạn.
2. **Store bị dispose hai lần:** đã điều chỉnh quyền sở hữu `InMemoryNutritionStore` để widget chỉ dispose store do chính widget tạo ra.
3. **Thao tác vuốt xóa chưa vượt ngưỡng:** đã sử dụng `fling` thay cho `drag` trong widget test để mô phỏng chính xác thao tác vuốt.
4. **Cảnh báo lint trong Workout:** đã bổ sung dấu ngoặc nhọn cho các câu lệnh điều kiện và xử lý phần tử tùy chọn trong `Row`.

---

## 8d. Phân tích các ca kiểm thử thành công và thất bại

| Mã | Chức năng | Dữ liệu/trường hợp | Kết quả mong đợi | Kết quả |
|---|---|---|---|---|
| TC01 | Thêm món | Tên món rỗng | Hiện lỗi, không đóng form | Đạt |
| TC02 | Thêm món | Calo là chữ | Từ chối dữ liệu, hiện lỗi | Đạt |
| TC03 | Thêm món | Khẩu phần bằng 0 | Từ chối dữ liệu, hiện lỗi | Đạt |
| TC04 | Thêm món | Dữ liệu hợp lệ | Trả về `Meal` và lưu thành công | Đạt |
| TC05 | Tìm món | Tìm kiếm không dấu | Tìm được món có dấu tương ứng | Đạt |
| TC06 | Nước uống | Thêm 250 ml | Tổng lượng nước tăng đúng 250 ml | Đạt |
| TC07 | Nước uống | Nhập số âm hoặc sai định dạng | Không lưu và hiện lỗi | Đạt |
| TC08 | Cân nặng | Nhập 70.5 kg | Lưu `HealthMetric` và thêm lịch sử | Đạt |
| TC09 | Cân nặng | Bỏ trống hoặc nhập sai | Không lưu dữ liệu | Đạt |
| TC10 | Buổi tập | Chọn loại tập và số phút | Tính calo và lưu buổi tập | Đạt |
| TC11 | Buổi tập | Chưa có dữ liệu | Hiện trạng thái chưa có buổi tập | Đạt |
| TC12 | Hành trình | Chưa có cân nặng | Hiện trạng thái chưa có dữ liệu | Đạt |
| TC13 | Hành trình | Có nhiều lần cập nhật cân nặng | Hiện đầy đủ lịch sử theo thời gian | Đạt |
| TC14 | Mục tiêu | Tăng/giảm bằng nút +/- | Giá trị thay đổi đúng bước | Đạt |
| TC15 | Firebase | Mất quyền ghi hoặc mất mạng | Hiện lỗi, ứng dụng không crash | Đạt theo thiết kế xử lý lỗi |
| TC16 | Điều hướng | Bấm Buổi tập ở Home | Chuyển sang Thể thao và mở form thêm tập | Đạt theo thiết kế chức năng |

### Phân tích trường hợp thành công

Các trường hợp nhập dữ liệu hợp lệ đều tạo hoặc cập nhật đúng đối tượng dữ liệu. Các phép tính BMI, calo, tiến độ mục tiêu và tổng lượng nước cho kết quả đúng với giá trị mong đợi. Các thao tác trên giao diện Nutrition cũng được kiểm tra và hoàn thành thành công.

### Phân tích trường hợp thất bại

Các trường hợp thất bại chủ yếu là dữ liệu rỗng, sai định dạng, bằng 0 hoặc số âm. Đây là các trường hợp được dự kiến trước. Ứng dụng không lưu dữ liệu sai mà hiển thị lỗi để người dùng sửa lại. Vì vậy, đây là **thất bại có kiểm soát**, không phải lỗi làm ứng dụng dừng hoạt động.

---

## 8e. Kiểm thử giao diện mobile

### Checklist giao diện cần kiểm tra trên Android emulator hoặc điện thoại

- [ ] Home không bị `RenderFlex overflow` trên màn hình hẹp.
- [ ] Các card pastel và chữ xanh đậm có độ tương phản dễ đọc.
- [ ] Bottom navigation chuyển đúng 5 tab.
- [ ] Shortcut **Thêm món** mở trực tiếp form thêm món.
- [ ] Shortcut **Uống nước** mở dialog nhập số ml.
- [ ] Shortcut **Cân nặng** mở dialog nhập số kg.
- [ ] Shortcut **Buổi tập** chuyển sang tab Thể thao và mở form thêm buổi tập.
- [ ] Nutrition cuộn được.
- [ ] Nutrition thêm, sửa và xóa món ăn được.
- [ ] Workout cuộn được.
- [ ] Workout thêm, sửa và xóa buổi tập được.
- [ ] Journey và Goal hiển thị rõ chữ trên nền sáng.
- [ ] Không xuất hiện overflow hoặc assertion khi thao tác bình thường.

### Trạng thái thực hiện

Các test tự động đã hoàn thành với kết quả **93/93 đạt**. Môi trường phát triển hiện tại là Windows, có Chrome và Edge; tại thời điểm lập báo cáo chưa có Android emulator hoặc điện thoại Android kết nối để thực hiện kiểm thử tương tác mobile trực tiếp.

Do đó, phần kiểm thử mobile cần được hoàn tất bằng một trong các phương án sau:

1. Kết nối điện thoại Android và chạy `flutter run`.
2. Mở Android Emulator rồi chạy ứng dụng.
3. Sử dụng máy Mac và Xcode nếu cần kiểm thử native iOS.

Phần này được ghi rõ là **chưa thực hiện trực tiếp trên thiết bị mobile**, không đánh dấu đạt khi chưa có bằng chứng kiểm thử.

---

## 3. Kết luận

Qua quá trình kiểm thử:

- Mã nguồn đạt kết quả **Flutter Analyzer: không có lỗi**.
- Bộ kiểm thử tự động đạt **93/93 test, tỷ lệ 100%**.
- Các chức năng chính về sức khỏe, dinh dưỡng, mục tiêu, buổi tập và hồ sơ người dùng đã có kiểm thử tương ứng.
- Các lỗi nhập liệu phổ biến được phát hiện và xử lý bằng validation.
- Các lỗi dữ liệu thiếu, lỗi quyền Firebase và lỗi thao tác người dùng đã có trạng thái xử lý phù hợp.
- Kiểm thử mobile thực tế vẫn cần được thực hiện bổ sung trên Android emulator hoặc điện thoại thật.

Nhìn chung, ứng dụng đạt yêu cầu kiểm thử tự động và có thể tiếp tục chuyển sang bước kiểm thử giao diện trên thiết bị thật trước khi phát hành.

## 4. Cách chạy lại kiểm thử

Từ thư mục `healthmate/`:

```bash
flutter analyze
flutter test
```

Chạy riêng từng nhóm test:

```bash
flutter test test/health_metric_test.dart
flutter test test/health_rules_test.dart
flutter test test/goal_rules_test.dart
flutter test test/nutrition_model_test.dart
flutter test test/nutrition_helpers_test.dart
flutter test test/nutrition_preset_test.dart
flutter test test/nutrition_store_test.dart
flutter test test/nutrition_add_meal_page_test.dart
flutter test test/nutrition_page_test.dart
flutter test test/workout_model_test.dart
flutter test test/user_model_test.dart
```
