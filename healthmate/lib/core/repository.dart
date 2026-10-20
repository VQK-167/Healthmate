import 'base_model.dart';
 
class Repository<T extends BaseEntity<T>> {
  final Map<String, T> _items = {};
 
  /// Tên kiểu đang lưu, lấy từ tham số generic T.
  String get typeName => T.toString();
 
  int get count => _items.length;
 
  List<T> get all => List<T>.unmodifiable(_items.values);
 
  /// Thêm mới hoặc ghi đè nếu trùng id.
  void add(T item) => _items[item.id] = item;
 
  T? getById(String id) => _items[id];
 
  bool remove(String id) => _items.remove(id) != null;
 
  List<T> where(bool Function(T item) test) =>
      _items.values.where(test).toList();
 
  List<Map<String, dynamic>> toJsonList() =>
      _items.values.map((e) => e.toJson()).toList();
}