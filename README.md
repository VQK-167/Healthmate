# Healthmate

## Bài tập Generics — HealthMate

### 1. Mục tiêu

Áp dụng kiến thức Generics, kế thừa (`extends`) và `Object` trong Dart để tổng quát hóa các đối tượng quản lý chỉ số sức khỏe của dự án HealthMate.

### 2. Các class được xây dựng

| Class | Chức năng |
|---|---|
| `HealthObject<T>` | Generic class dùng chung |
| `WeightMetric` | Quản lý giá trị cân nặng (`double`) |
| `HeartRateMetric` | Quản lý nhịp tim (`int`) |
| `WaterMetric` | Quản lý lượng nước (`double`) |
| `HealthMetric` | Model sức khỏe thực tế, kế thừa `HealthObject<String>` |

### 3. Kiến thức áp dụng

- **Generics:** Sử dụng `T` để xây dựng class có thể làm việc với nhiều kiểu dữ liệu.
- **Extends:** Các class chỉ số sức khỏe kế thừa từ `HealthObject<T>`.
- **Object:** Sử dụng `List<Object>` để lưu nhiều loại đối tượng và xử lý qua hàm `showObject()`.
- **Type / runtimeType:** Xác định kiểu thực tế của đối tượng tại thời điểm chạy chương trình.

### 4. Cấu trúc bài tập

```text
lib/
├── exercises/
│   └── generic/
│       ├── health_object.dart
│       ├── weight_metric.dart
│       ├── heart_rate_metric.dart
│       ├── water_metric.dart
│       └── generic_demo.dart
└── models/
    └── health_metric.dart
```

### 5. Hướng dẫn chạy

Tại thư mục gốc dự án:

```bash
dart run lib/exercises/generic/generic_demo.dart
```

Kiểm tra dự án:

```bash
flutter analyze
flutter test
```

### 6. Kết quả thực hiện

Chương trình khởi tạo các đối tượng cân nặng, nhịp tim, lượng nước và bản ghi sức khỏe; sử dụng một hàm chung để hiển thị thông tin đối tượng.

Kết quả kiểm tra:

- Demo Generics chạy thành công.
- BMI tính được: `22.49`.
- Phân loại BMI: `Bình thường`.
- `flutter analyze`: 0 error, 0 warning, 11 info.
- `flutter test`: 1 test passed.

