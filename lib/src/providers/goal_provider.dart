import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalProvider extends ChangeNotifier {
  int _weeklyGoal = 5; // Default weekly goal

  int get weeklyGoal => _weeklyGoal;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _weeklyGoal = prefs.getInt('weeklyGoal') ?? 5; // Default to 5 if not set
    notifyListeners();
  }

  Future<void> setWeeklyGoal(int goal) async {
    _weeklyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weeklyGoal', _weeklyGoal);
    notifyListeners();
  }
}