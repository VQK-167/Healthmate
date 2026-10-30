# Giải thích phần Thể thao và Mục tiêu (Hưng)

## 1. Phần này làm gì (nói 1 câu)
Tab **Thể thao** cho người dùng ghi lại các buổi tập (thêm, sửa, xoá), xem tổng kết và ghi bước chân hôm nay.
Trang **Mục tiêu** cho đặt mục tiêu (bước chân, calo, số buổi tập) và tự cập nhật tiến độ từ dữ liệu thật. Dữ liệu lưu trên **Firebase Firestore**.

## 2. Luồng dữ liệu (quan trọng nhất)

```
Giao diện (screens)  →  Repository  →  FirestoreRepository (của Huy)  →  Firestore
 workout_page.dart       workout_repository.dart     firestore_repository.dart      (đám mây)
 goal_page.dart          goal_repository.dart
```
- **Giao diện** chỉ lo hiển thị và nhận thao tác của người dùng.
- **Repository** lo nói chuyện với Firestore (thêm, sửa, xoá, đọc) và kiểm tra dữ liệu.
- **Model** (`workout.dart`) là "khuôn" của dữ liệu và biết đổi qua lại giữa object và Map.
- **GoalRules** (`goal_rules.dart`) chứa các phép tính, không dùng Firestore nên dễ viết test.

Lý do tách lớp: sửa chỗ này không ảnh hưởng chỗ kia, và dễ kiểm thử.

## 3. Các file và vai trò

| File | Vai trò |
|---|---|
| `models/workout.dart` | Lớp `Workout` (buổi tập) và `Goal` (mục tiêu), có `toMap()` / `fromMap()` |
| `repositories/workout_repository.dart` | Thêm, sửa, xoá, đọc buổi tập; ghi bước chân; các hàm cho Home |
| `repositories/goal_repository.dart` | Tạo, đọc, xoá mục tiêu |
| `core/goal_rules.dart` | Tính calo (MET), tiến độ, chuỗi ngày, giá trị hiện tại của mục tiêu |
| `screens/workout_page.dart` | Giao diện Tập luyện: tổng kết, bước chân, lịch sử, hộp thoại thêm/sửa |
| `screens/goal_page.dart` | Giao diện Mục tiêu: danh sách, thanh tiến độ, hộp thoại tạo |
| `test/` | Unit test cho model và các hàm tính toán |

## 4. Đối chiếu 5 việc được giao
1. **Thiết kế giao diện**: `workout_page.dart`, `goal_page.dart`.
2. **Model có toMap/fromMap**: `workout.dart`.
3. **Repository thêm, sửa, xoá, đọc**: dùng `FirestoreRepository` của Huy (`_workouts.add / set / delete / watchAll`).
4. **Nối giao diện với repository**: bấm Lưu thì gọi `_repo.addWorkout(...)` và dữ liệu lên Firestore thật.
5. **Xử lý lỗi và unit test**: hàm `_run` bắt lỗi và báo bằng SnackBar; repository kiểm tra dữ liệu (`ArgumentError`); thư mục `test/`.

## 5. Giải thích các đoạn code chính

**toMap / fromMap**: Firestore lưu dữ liệu dạng Map (cặp khoá và giá trị). `toMap()` đổi object `Workout` thành Map để ghi lên; `fromMap()` làm ngược lại khi đọc xuống. Nếu thiếu trường thì dùng giá trị mặc định (`?? 0`, `?? ''`) để app không bị lỗi.

**Stream và StreamBuilder**: `watchWorkouts()` trả về một `Stream`, tức là dữ liệu chảy về liên tục. Khi Firestore có thay đổi (thêm, sửa, xoá), `StreamBuilder` tự vẽ lại giao diện, không cần bấm tải lại.

**Vì sao tạo stream trong `initState`**: nếu gọi trong `build()` thì mỗi lần giao diện vẽ lại sẽ đăng ký stream mới, gây tốn truy vấn và nhấp nháy. `initState` chỉ chạy một lần.

**Ước tính calo bằng MET**: `kcal = MET × 3.5 × cân nặng(kg) / 200 × số phút`. Ví dụ chạy bộ (MET 8), 60 kg, 30 phút: 8 × 3.5 × 60 / 200 × 30 = **252 kcal**. MET là mức tiêu hao năng lượng của từng loại bài tập (đi bộ 3.5, chạy bộ 8, đạp xe 7.5, yoga 2.5, gym 5).

**Tiến độ mục tiêu tự tính**: không bắt người dùng nhập tay. `GoalRules.currentValue` lấy dữ liệu thật:
- loại `steps`: số bước hôm nay (từ `daily_logs`);
- loại `calories`: tổng calo của các buổi tập hôm nay;
- loại `workouts`: số buổi tập trong 7 ngày gần nhất.
Rồi `progress = current / target`, tối đa 100%.

**Chuỗi ngày tập (`streak`)**: đếm lùi từng ngày, ngày nào có tập thì cộng 1, gặp ngày không tập thì dừng. Nếu hôm nay chưa tập thì bắt đầu đếm từ hôm qua để chuỗi chưa bị đứt.

**Cộng bước chân bằng transaction**: `addSteps` đọc số bước cũ rồi ghi số mới trong một transaction, để nếu hai lần ghi cùng lúc thì không bị mất dữ liệu. Mỗi người mỗi ngày có một tài liệu `daily_logs` với id dạng `uid_2026-10-30`.

**Lọc theo userId**: mỗi buổi tập lưu kèm `userId`, truy vấn dùng `where('userId', isEqualTo: uid)` nên mỗi người chỉ thấy dữ liệu của mình.

**Sắp xếp trong Dart, không dùng `orderBy` của Firestore**: nếu vừa `where('userId')` vừa `orderBy('date')` thì Firestore bắt buộc tạo *composite index* (lỗi lúc đầu). Em lọc bằng Firestore rồi `sort` bằng Dart, dữ liệu mỗi người ít nên đủ nhanh và cả nhóm không phải cấu hình thêm.

**Xử lý lỗi (`_run`)**: bọc thao tác ghi bằng `try/catch`: dữ liệu sai → `ArgumentError` báo "không hợp lệ"; lỗi Firestore → báo mã lỗi; quá 10 giây chưa phản hồi (mất mạng) → báo dữ liệu sẽ tự đồng bộ khi có mạng. Người dùng luôn thấy thông báo, app không bị văng.

**Unit test**: kiểm thử các hàm thuần: tính calo, tiến độ không vượt 100%, chuỗi ngày (kể cả trường hợp đứt chuỗi), tổng phút bỏ số âm, `toMap/fromMap`. Chạy bằng `flutter test`.

## 6. Câu cô có thể hỏi và cách trả lời

1. **Dữ liệu lưu ở đâu, cấu trúc thế nào?**
   Firestore, 3 collection: `workouts` (buổi tập), `goals` (mục tiêu), `daily_logs` (bước chân mỗi ngày). Mỗi tài liệu có `userId`.
2. **Vì sao không gọi Firestore thẳng trong giao diện?**
   Để tách trách nhiệm: giao diện chỉ hiển thị, repository lo dữ liệu. Dễ sửa, dễ test, và nhiều màn hình có thể dùng chung (ví dụ Home gọi `watchStepsToday`).
3. **`FirestoreRepository` là gì, ai viết?**
   Lớp chung do Huy viết, có sẵn thêm, sửa, xoá, đọc cho bất kỳ model nào. Repository của em dùng lại nó cho collection `workouts` và `goals`.
4. **Stream khác Future thế nào?**
   Future trả về một lần; Stream trả về nhiều lần, mỗi lần dữ liệu đổi. Nên dùng Stream để danh sách tự cập nhật.
5. **`toMap` và `fromMap` để làm gì?**
   Đổi qua lại giữa object và dữ liệu Firestore (xem mục 5).
6. **Tính calo thế nào, có chính xác không?**
   Dùng công thức MET, là ước tính (không phải đo thực tế). Độ chính xác phụ thuộc cân nặng và loại bài tập người dùng nhập.
7. **Tiến độ mục tiêu lấy từ đâu?**
   Tự tính từ dữ liệu thật (xem mục 5), không nhập tay.
8. **Nếu mất mạng thì sao?**
   Firestore lưu tạm và đồng bộ lại khi có mạng. App báo cho người dùng sau 10 giây nếu chưa kết nối.
9. **Vì sao dùng `userId`?**
   Để mỗi người chỉ đọc và ghi dữ liệu của mình. Ngoài ra nên bật Firestore Rules chỉ cho phép user đã đăng nhập đọc/ghi tài liệu có `userId` trùng UID của họ.
10. **Phần Home dùng phần của em thế nào?**
    Home gọi các hàm đã viết sẵn: `watchStepsToday()`, `watchCaloriesBurnedToday()`, `addSteps(steps)`, `watchGoal(type)`.
11. **Em kiểm tra đầu vào thế nào?**
    Hộp thoại kiểm tra số phút > 0, cân nặng > 0; repository kiểm tra lần nữa (tên không rỗng, phút > 0, calo ≥ 0) và ném `ArgumentError`.
12. **Unit test kiểm tra gì?**
    Các hàm tính toán trong `goal_rules.dart` và việc đổi qua lại của model (xem mục 5).

## 7. Cách demo nhanh (2 phút)
1. Vào tab Thể thao: thêm một buổi tập (chọn Chạy bộ, 30 phút), thấy tổng kết và lịch sử cập nhật ngay.
2. Chạm vào buổi tập để sửa; bấm thùng rác để xoá.
3. Bấm **+** ở thẻ bước chân, nhập 3000.
4. Bấm biểu tượng cờ, tạo mục tiêu bước chân 10000, thấy thanh tiến độ khoảng 30%.
5. Mở Firebase Console, chỉ cho cô thấy dữ liệu trong `workouts`, `goals`, `daily_logs`.

## 8. Hạn chế (nói thật nếu cô hỏi)
- Calo chỉ là ước tính theo MET.
- Mục tiêu tính theo ngày hoặc 7 ngày gần nhất, chưa có lịch sử các mục tiêu đã hoàn thành.
- Bước chân phải nhập tay, chưa đọc từ cảm biến điện thoại.
- Chưa có biểu đồ thống kê theo tuần (có thể bổ sung sau).
