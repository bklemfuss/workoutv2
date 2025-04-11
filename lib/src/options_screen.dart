import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';
import 'theme/colors.dart'; // Import AppColors for custom colors

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme
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
            color: AppColors.secondary, // Use secondary color for card background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                option['title']!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, // Use primary text color
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward,
                color: AppColors.textPrimary, // Use primary text color for the icon
              ),
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