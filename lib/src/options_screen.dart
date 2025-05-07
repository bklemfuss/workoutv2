import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/unit_provider.dart';
import 'providers/goal_provider.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final unitProvider = Provider.of<UnitProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);

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
              style: theme.textTheme.bodyMedium,
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
              style: theme.textTheme.bodyMedium,
            ),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: theme.cardColor, // Use cardColor for dropdown background
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                DropdownMenuItem(value: 'French', child: Text('French')),
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
              style: theme.textTheme.bodyMedium,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleDarkMode(value);
            },
          ),
          ListTile(
            title: Text(
              'Font Size',
              style: theme.textTheme.bodyMedium,
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
              style: theme.textTheme.bodyMedium,
            ),
            trailing: DropdownButton<String>(
              value: unitProvider.unitSystem,
              dropdownColor: theme.cardColor,
              items: const [
                DropdownMenuItem(value: 'Imperial', child: Text('Imperial')),
                DropdownMenuItem(value: 'Metric', child: Text('Metric')),
              ],
              onChanged: (value) {
                if (value != null) {
                  unitProvider.setUnitSystem(value);
                }
              },
            ),
          ),

          // Goals Section
          _buildSectionHeader('Goals', theme),
          ListTile(
            title: Text(
              'Weekly Goal',
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Slider(
              value: goalProvider.weeklyGoal.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              label: '${goalProvider.weeklyGoal} workouts',
              onChanged: (value) {
                goalProvider.setWeeklyGoal(value.toInt());
              },
            ),
          ),

          // About Section
          _buildSectionHeader('About', theme),
          ListTile(
            title: Text(
              'App Version',
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Text(
              '1.0.0',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              // Handle privacy policy tap
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 4, // Index for Options tab (5th tab)
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}