import 'dart:convert';
 
/// Lớp cha của MỌI model.
/// Kế thừa từ Object (class gốc của Dart) và override ==, hashCode, toString
/// để cả project dùng chung một cách so sánh và in đối tượng.
abstract class BaseModel {
  const BaseModel();
 
  /// Mỗi model tự định nghĩa cách chuyển thành JSON.
  Map<String, dynamic> toJson();
 
  /// "Class class" của Dart: Type chứa thông tin lớp lúc chạy.
  Type get type => runtimeType;
 
  /// Tên lớp dạng chuỗi, ví dụ "Food", "MealEntry".
  String get className => runtimeType.toString();
 
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaseModel &&
          other.runtimeType == runtimeType &&
          jsonEncode(other.toJson()) == jsonEncode(toJson()));
 
  @override
  int get hashCode => Object.hash(runtimeType, jsonEncode(toJson()));
 
  @override
  String toString() => '$className(${jsonEncode(toJson())})';
}
 
/// Đối tượng Generics: model có id.
/// T chính là lớp con cụ thể, nên copyWith trả đúng kiểu (Food, MealEntry...).
abstract class BaseEntity<T extends BaseEntity<T>> extends BaseModel {
  final String id;
 
  const BaseEntity({required this.id});
 
  /// Bản sao có thể đổi một số trường. Lớp con thêm các tham số riêng.
  T copyWith({String? id});
 
  /// Hai entity bằng nhau khi cùng lớp và cùng id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaseEntity &&
          other.runtimeType == runtimeType &&
          other.id == id);
 
  @override
  int get hashCode => Object.hash(runtimeType, id);
}
 
/// Dùng Type làm khóa để tạo đối tượng tổng quát từ JSON.
/// Ví dụ: `ModelRegistry.create<Food>(json)`
class ModelRegistry {
  static final Map<Type, BaseModel Function(Map<String, dynamic>)> _factories =
      {};
 
  static void register<T extends BaseModel>(
      T Function(Map<String, dynamic>) factory) {
    _factories[T] = factory;
  }
 
  static bool isRegistered<T extends BaseModel>() =>
      _factories.containsKey(T);
 
  static T create<T extends BaseModel>(Map<String, dynamic> json) {
    final factory = _factories[T];
    if (factory == null) {
      throw StateError('Chưa đăng ký factory cho $T');
    }
    return factory(json) as T;
  }
}