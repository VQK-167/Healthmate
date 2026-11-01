import '../services/auth_service.dart';
import 'in_memory_nutrition_store.dart';
import 'nutrition_repository.dart';

NutritionStore createDefaultNutritionStore() {
  final uid = AuthService().currentUser?.uid;
  if (uid == null) return InMemoryNutritionStore();
  return NutritionRepository(uid: uid);
}