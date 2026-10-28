import '../core/base_model.dart';// ignore_for_file: avoid_print
import '../core/repository.dart';
import '../models/diary.dart';
import '../models/nutrition.dart';
 
void main() {
  ModelRegistry.register<Food>(Food.fromJson);
  ModelRegistry.register<MealEntry>(MealEntry.fromJson);
 
  const com = Food(
    id: 'f1',
    name: 'Cơm tấm sườn nướng',
    servingSize: 1,
    servingUnit: 'dĩa',
    nutrition: Nutrition(calories: 550, protein: 25, carbs: 65, fat: 18),
  );
  const ga = Food(
    id: 'f2',
    name: 'Ức gà luộc',
    nutrition: Nutrition(calories: 165, protein: 31, carbs: 0, fat: 3.6),
  );
 
  print('===== 1. Object class: toString, ==, hashCode =====');
  print(com); // toString kế thừa từ BaseModel
  print('com == com.copyWith(): ${com == com.copyWith()}'); // true
  print('com == ga: ${com == ga}'); // false
  print('hashCode: ${com.hashCode}');
 
  print('\n===== 2. Type / runtimeType (Class class) =====');
  final Object obj = com; // coi như một Object bất kỳ
  print('runtimeType: ${obj.runtimeType}');
  print('className: ${com.className}');
  print('type == Food: ${com.type == Food}');
  print('obj is BaseEntity<Food>: ${obj is BaseEntity<Food>}');
  print('obj is BaseModel: ${obj is BaseModel}');
 
  print('\n===== 3. Generics: Repository<T> dùng chung =====');
  final foodRepo = Repository<Food>()
    ..add(com)
    ..add(ga);
  print('Repository<${foodRepo.typeName}> có ${foodRepo.count} món');
  print('getById(f2): ${foodRepo.getById('f2')?.name}');
  print('Món trên 200 kcal: '
      '${foodRepo.where((f) => f.nutrition.calories > 200).map((f) => f.name)}');
 
  final entryRepo = Repository<MealEntry>()
    ..add(MealEntry(
      id: 'e1',
      food: com,
      mealType: MealType.lunch,
      loggedAt: DateTime(2026, 10, 4, 12),
    ))
    ..add(MealEntry(
      id: 'e2',
      food: ga,
      quantity: 2,
      mealType: MealType.dinner,
      loggedAt: DateTime(2026, 10, 4, 19),
    ));
  print('Repository<${entryRepo.typeName}> có ${entryRepo.count} entry');
 
  final diary = DiaryDay(
    userId: 'demo',
    date: DateTime(2026, 10, 4),
    entries: entryRepo.all,
  );
  print('Tổng calo trong ngày: ${diary.totalNutrition.calories} kcal');
  print('Còn lại: ${diary.caloriesRemaining} kcal');
 
  print('\n===== 4. ModelRegistry: tạo đối tượng từ Type =====');
  final food2 = ModelRegistry.create<Food>(com.toJson());
  print('Tạo lại từ JSON: ${food2.name}, bằng bản gốc: ${food2 == com}');
  print('Food đã đăng ký: ${ModelRegistry.isRegistered<Food>()}');
  print('DiaryDay đã đăng ký: ${ModelRegistry.isRegistered<DiaryDay>()}');
}