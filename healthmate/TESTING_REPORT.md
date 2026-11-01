# HealthMate — Báo cáo kiểm thử và kiểm định

## Phạm vi

Tài liệu này phục vụ Câu 8 (Kiểm thử và Kiểm định) của ứng dụng HealthMate.

## 8a — Bắt lỗi

Ứng dụng xử lý các nhóm lỗi sau:

- Dữ liệu nhập rỗng hoặc sai định dạng trong các form.
- Số âm, số 0 hoặc giá trị không hợp lệ cho calo, khẩu phần, nước, cân nặng và thời lượng tập.
- Người dùng chưa đăng nhập hoặc phiên đăng nhập không còn hợp lệ.
- Dữ liệu Firebase/Firestore bị thiếu hoặc có giá trị null.
- Lỗi quyền Firestore, mất mạng và timeout khi ghi dữ liệu.
- Người dùng hủy dialog hoặc thoát khỏi màn hình thêm/sửa.
- Trạng thái chưa có dữ liệu ở các màn hình Nutrition, Workout, Health và Journey.

Thông báo lỗi được hiển thị bằng validation trên form hoặc SnackBar để người dùng biết thao tác có thành công hay không.

## 8b — Unit test

Các test hiện có trong thư mục `test/`:

| Nhóm | File kiểm thử |
|---|---|
| Health metric | `health_metric_test.dart` |
| Quy tắc sức khỏe/BMI/huyết áp/nhịp tim | `health_rules_test.dart` |
| Mục tiêu và tính calo MET | `goal_rules_test.dart` |
| Model Nutrition | `nutrition_model_test.dart` |
| Helper Nutrition | `nutrition_helpers_test.dart` |
| Preset món ăn | `nutrition_preset_test.dart` |
| Nutrition store | `nutrition_store_test.dart` |
| Form thêm món | `nutrition_add_meal_page_test.dart` |
| Màn hình Nutrition | `nutrition_page_test.dart` |
| Model Workout | `workout_model_test.dart` |
| Model User/Profile | `user_model_test.dart` |

Các trường hợp đã kiểm thử gồm dữ liệu hợp lệ, dữ liệu rỗng, sai kiểu, giá trị biên, dữ liệu không hợp lệ, thêm/sửa/xóa và trạng thái không có dữ liệu.

## 8c — Kiểm thử toàn bộ ứng dụng

Lệnh kiểm thử:

```bash
flutter analyze
flutter test
```

Kết quả analyzer hiện tại:

```text
No issues found!
```

Nhóm test mở rộng đã chạy thành công:

```text
93 tests passed
```

Kết quả này bao gồm toàn bộ test logic, model, store, validation, Add Meal và Nutrition UI. Test Nutrition UI đã được điều chỉnh để không chờ vô hạn các `StreamBuilder` và đã chạy thành công toàn bộ.

## 8d — Các ca kiểm thử thành công/thất bại

| Mã | Chức năng | Dữ liệu/trường hợp | Kết quả mong đợi |
|---|---|---|---|
| TC01 | Thêm món | Tên món rỗng | Hiện lỗi, không đóng form |
| TC02 | Thêm món | Calo là chữ | Từ chối, hiện lỗi |
| TC03 | Thêm món | Khẩu phần bằng 0 | Từ chối, hiện lỗi |
| TC04 | Thêm món | Dữ liệu hợp lệ | Trả về Meal và lưu được |
| TC05 | Tìm món | Tìm không dấu | Tìm được món có dấu |
| TC06 | Nước uống | Thêm 250 ml | Tổng nước tăng đúng 250 ml |
| TC07 | Nước uống | Nhập số không hợp lệ/âm | Không lưu, báo lỗi |
| TC08 | Cân nặng | Nhập 70.5 kg | Lưu HealthMetric và thêm lịch sử Journey |
| TC09 | Cân nặng | Bỏ trống hoặc số không hợp lệ | Không lưu |
| TC10 | Buổi tập | Chọn loại tập và nhập phút | Tính calo và lưu Workout |
| TC11 | Buổi tập | Không có dữ liệu | Hiện trạng thái chưa có buổi tập |
| TC12 | Hành trình | Chưa có cân nặng | Hiện `-- kg` và hướng dẫn cập nhật |
| TC13 | Hành trình | Có nhiều lần cập nhật cân nặng | Hiện đầy đủ lịch sử theo thời gian |
| TC14 | Mục tiêu | Tăng/giảm bằng nút +/- | Giá trị thay đổi đúng bước |
| TC15 | Firebase | Mất quyền ghi hoặc mất mạng | Hiện thông báo lỗi, app không crash |
| TC16 | Điều hướng | Bấm Buổi tập ở Home | Chuyển tab Thể thao và mở form thêm tập |

## 8e — Kiểm thử giao diện mobile

Checklist thực hiện trên emulator/điện thoại:

- [ ] Home không overflow ở màn hình hẹp.
- [ ] Các card pastel và chữ xanh đậm có độ tương phản dễ đọc.
- [ ] Bottom navigation chuyển đúng 5 tab.
- [ ] Shortcut Thêm món mở form thêm món.
- [ ] Shortcut Uống nước mở dialog nhập ml.
- [ ] Shortcut Cân nặng mở dialog nhập kg.
- [ ] Shortcut Buổi tập mở tab Thể thao và dialog thêm buổi tập.
- [ ] Nutrition cuộn được và thêm/sửa/xóa món hoạt động.
- [ ] Workout cuộn được, thêm/sửa/xóa buổi tập hoạt động.
- [ ] Journey và Goal bottom sheet không còn chữ trắng khó đọc trên nền sáng.
- [ ] Không có RenderFlex overflow hoặc assertion khi thao tác bình thường.

Thiết bị phát hiện trong môi trường phát triển hiện tại: Windows, Chrome và Edge. Chưa có Android emulator/điện thoại kết nối tại thời điểm kiểm tra; cần đánh dấu checklist mobile sau khi kết nối thiết bị Android.

## Cách chạy kiểm thử

Chạy từ thư mục `healthmate/`:

```bash
flutter analyze
flutter test test/health_metric_test.dart
flutter test test/health_rules_test.dart
flutter test test/goal_rules_test.dart
flutter test test/nutrition_model_test.dart
flutter test test/nutrition_helpers_test.dart
flutter test test/nutrition_preset_test.dart
flutter test test/nutrition_store_test.dart
flutter test test/nutrition_add_meal_page_test.dart
flutter test test/workout_model_test.dart
flutter test test/nutrition_page_test.dart
```
