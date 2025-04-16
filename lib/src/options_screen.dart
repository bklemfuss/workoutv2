import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/unit_provider.dart'; // Import UnitProvider
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'theme/colors.dart'; // Import AppColors for custom colors

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  // State variables for toggles, dropdowns, etc.
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';
  String selectedTheme = 'Light';
  double fontSize = 16.0;
  int weeklyGoal = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final unitProvider = Provider.of<UnitProvider>(context); // Access UnitProvider

    return Scaffold(
      appBar: const AppToolbar(title: 'Options'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Section
          _buildSectionHeader('General', theme),
          SwitchListTile(
            title: Text(
              'Enable Notifications',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: Text(
              'Language',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: AppColors.secondary, // Optional: Dropdown background color
              items: const [
                DropdownMenuItem(
                  value: 'English',
                  child: Text(
                    'English',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DropdownMenuItem(
                  value: 'Spanish',
                  child: Text(
                    'Spanish',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DropdownMenuItem(
                  value: 'French',
                  child: Text(
                    'French',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
            ),
          ),

          // Appearance Section
          _buildSectionHeader('Appearance', theme),
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleDarkMode(value);
            },
          ),
          ListTile(
            title: Text(
              'Font Size',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            subtitle: Slider(
              value: themeProvider.fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 6,
              label: '${themeProvider.fontSize.toInt()}',
              onChanged: (value) {
                themeProvider.updateFontSize(value);
              },
            ),
          ),

          // Preferences Section
          _buildSectionHeader('Preferences', theme),
          ListTile(
            title: Text(
              'Units',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            trailing: DropdownButton<String>(
              value: unitProvider.unitSystem, // Get the current unit system
              dropdownColor: AppColors.secondary, // Optional: Dropdown background color
              items: const [
                DropdownMenuItem(
                  value: 'Imperial',
                  child: Text(
                    'Imperial',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DropdownMenuItem(
                  value: 'Metric',
                  child: Text(
                    'Metric',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  unitProvider.setUnitSystem(value); // Update the unit system
                }
              },
            ),
          ),

          // Goals Section
          _buildSectionHeader('Goals', theme),
          ListTile(
            title: Text(
              'Weekly Goal',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            subtitle: Slider(
              value: weeklyGoal.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$weeklyGoal workouts',
              onChanged: (value) {
                setState(() {
                  weeklyGoal = value.toInt();
                });
              },
            ),
          ),

          // About Section
          _buildSectionHeader('About', theme),
          ListTile(
            title: Text(
              'App Version',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            subtitle: Text(
              '1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            onTap: () {
              // Handle privacy policy tap
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 3, // Index for Options
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}