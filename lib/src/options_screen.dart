import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      {'title': 'General', 'route': '/general_settings'},
      {'title': 'Appearance', 'route': '/appearance_settings'},
      {'title': 'Preferences', 'route': '/preferences_settings'},
      {'title': 'Goals', 'route': '/goals_settings'},
      {'title': 'About', 'route': '/about_settings'},
    ];

    return Scaffold(
      appBar: const AppToolbar(title: 'Options'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                option['title']!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, option['route']!);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 3, // Index for Options
      ),
      floatingActionButton: const FloatingStartNewWorkoutButton(),
    );
  }
}