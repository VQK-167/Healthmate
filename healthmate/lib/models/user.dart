class User {
  String id = "";
  String name = "";
  String email = "";
  int age = 0;
  String gender = "";
  double height = 0;
  double weight = 0;

  String vipLevel = "Platinum";
  int points = 734000;
  int unreadNotifications = 3;

  void setUser(
    String id,
    String name,
    String email,
    int age,
    String gender,
    double height,
    double weight,
  ) {
    this.id = id;
    this.name = name.trim();
    this.email = email.trim();
    this.age = age < 0 ? 0 : age;
    this.gender = gender;
    this.height = height > 0 ? height : 0;
    this.weight = weight > 0 ? weight : 0;
  }

  String getFullInfo() {
    return 'ID: $id - Tên: $name - Email: $email - Tuổi: $age - Giới tính: $gender';
  }
}
