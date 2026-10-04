class User {
  String id = "";
  String name = "";
  String email = "";
  int age = 0;
  String gender = "";
  double height = 0; 
  double weight = 0; 


  void setUser(String id, String name, String email, int age, String gender,
      double height, double weight) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.age = age;
    this.gender = gender;
    this.height = height;
    this.weight = weight;
  }


  String getFullInfo() {
    return 'ID: $id - Tên: $name - Email: $email - Tuổi: $age - Giới tính: $gender';
  }


  double getBMI() {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }


  String getBMIStatus() {
    double bmi = getBMI();
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }
}