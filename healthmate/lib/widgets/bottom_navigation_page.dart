import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/health_page.dart';
import '../screens/home_page.dart';
import '../screens/nutrition_page.dart';
import '../screens/user_page.dart';
import '../screens/workout_page.dart';
import '../services/auth_service.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  final GlobalKey<WorkoutPageState> _workoutKey = GlobalKey<WorkoutPageState>();
  int _index = 0;

  void _openWorkoutForm() {
    setState(() => _index = 3);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _workoutKey.currentState?.openAddWorkoutDialog();
    });
  }

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final uid = auth.currentUser?.uid;

    return StreamBuilder<AppUser?>(
      stream: uid == null
          ? const Stream<AppUser?>.empty()
          : auth.watchProfile(uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final pages = <Widget>[
          HomePage(onSelectTab: _goTo, onOpenWorkout: _openWorkoutForm),
          const HealthPage(),
          NutritionPage(
            calorieGoal: (profile?.dailyCalorieTarget ?? 2000).toDouble(),
            waterGoalMl: profile?.dailyWaterTargetMl,
          ),
          WorkoutPage(key: _workoutKey),
          UserPage(onSelectTab: _goTo),
        ];

        return Scaffold(
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _goTo,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.monitor_heart_outlined),
                selectedIcon: Icon(Icons.monitor_heart),
                label: 'Sức khỏe',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_outlined),
                selectedIcon: Icon(Icons.restaurant),
                label: 'Dinh dưỡng',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center),
                label: 'Thể thao',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Hồ sơ',
              ),
            ],
          ),
        );
      },
    );
  }
}
