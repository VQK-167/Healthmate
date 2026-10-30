# Phần Hưng – Tập luyện và Mục tiêu

Xem `GIAI_THICH_HUNG.md` để biết luồng dữ liệu, giải thích từng file và các câu hỏi thường gặp.

Các tệp thuộc phạm vi Hưng:
- `lib/models/workout.dart`: model Workout và Goal, có `toMap/fromMap`.
- `lib/repositories/workout_repository.dart`: thêm, sửa, xoá, đọc buổi tập; ghi bước chân; hàm cho Home.
- `lib/repositories/goal_repository.dart`: tạo, đọc, xoá mục tiêu.
- `lib/core/goal_rules.dart`: ước tính calo theo MET, tiến độ, chuỗi ngày, giá trị hiện tại của mục tiêu.
- `lib/screens/workout_page.dart`: giao diện Tập luyện.
- `lib/screens/goal_page.dart`: giao diện Mục tiêu.
- `test/`: unit test.

## Chạy thử
Trong thư mục `healthmate`: `flutter pub get`, `flutter test`, `flutter run -d chrome`.
Dữ liệu lưu trong collection `workouts`, `goals`, `daily_logs`.

Hàm cho Home: `watchStepsToday()`, `watchCaloriesBurnedToday()`, `addSteps(steps)`, `watchGoal(type)`.
