import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnitProvider extends ChangeNotifier {
  String _unitSystem = 'Imperial'; // Default to Imperial

  String get unitSystem => _unitSystem;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _unitSystem = prefs.getString('unitSystem') ?? 'Imperial';
    notifyListeners();
  }

  Future<void> setUnitSystem(String unit) async {
    _unitSystem = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unitSystem', _unitSystem);
    notifyListeners();
  }
}