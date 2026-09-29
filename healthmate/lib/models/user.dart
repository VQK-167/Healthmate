class User {
<<<<<<< Updated upstream
  String id = "";
  String name = "";
  String email = "";
  int age = 0;
  String gender = "";
  double height = 0; // cm
  double weight = 0; // kg

  // Phương thức set - gán dữ liệu, có kiểm tra hợp lệ
  void setUser(String id, String name, String email, int age, String gender,
      double height, double weight) {
=======
  String id;
  String name;
  String email;
  int age;
  String gender;
  double height; // cm
  double weight; // kg

  // Constructor hỗ trợ cả khởi tạo mặc định lẫn truyền tham số linh hoạt
  User({
    this.id = '',
    this.name = '',
    this.email = '',
    this.age = 0,
    this.gender = '',
    this.height = 0,
    this.weight = 0,
  });

  // Giữ lại phương thức setUser để cập nhật thông tin khi cần
  void setUser(
    String id,
    String name,
    String email,
    int age,
    String gender,
    double height,
    double weight,
  ) {
>>>>>>> Stashed changes
    this.id = id;
    this.name = name.trim();
    this.email = email.trim();
    this.age = age < 0 ? 0 : age;
    this.gender = gender;
    this.height = height > 0 ? height : 0;
    this.weight = weight > 0 ? weight : 0;
  }

<<<<<<< Updated upstream
  // Lấy thông tin cơ bản
=======
>>>>>>> Stashed changes
  String getFullInfo() {
    return 'ID: $id - Tên: $name - Email: $email - Tuổi: $age - Giới tính: $gender';
  }

<<<<<<< Updated upstream
  // Tính BMI - tránh lỗi chia cho 0 nếu chưa có dữ liệu
  double getBMI() {
    if (height <= 0 || weight <= 0) return 0;
=======
  // Getter tính chỉ số BMI
  double get bmi {
    if (height <= 0) return 0;
>>>>>>> Stashed changes
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

<<<<<<< Updated upstream
  // Phân loại tình trạng cân nặng
  String getBMIStatus() {
    double bmi = getBMI();
    if (bmi == 0) return 'Chưa có dữ liệu';
=======
  // Getter đánh giá tình trạng cơ thể dựa trên BMI
  String get bmiStatus {
    if (bmi <= 0) return 'Chưa xác định';
>>>>>>> Stashed changes
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }
<<<<<<< Updated upstream

  // Kiểm tra email hợp lệ cơ bản
  bool isValidEmail() {
    return email.contains('@') && email.contains('.');
  }

  @override
  String toString() {
    return '${getFullInfo()} - BMI: ${getBMI().toStringAsFixed(1)} (${getBMIStatus()})';
  }
}
=======
}
>>>>>>> Stashed changes
