import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/unit_provider.dart';
import 'providers/goal_provider.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';

class OptionsScreen extends StatefulWidget {
  final ValueChanged<String>? onLocaleChanged;
  const OptionsScreen({super.key, this.onLocaleChanged});

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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppToolbar(title: loc.optionsTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Section
          _buildSectionHeader(loc.general, theme),
          SwitchListTile(
            title: Text(
              loc.enableNotifications,
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
              loc.language,
              style: theme.textTheme.bodyMedium,
            ),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: theme.cardColor, // Use cardColor for dropdown background
              items: [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                DropdownMenuItem(value: 'French', child: Text('French')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
                if (widget.onLocaleChanged != null) {
                  if (value == 'English') widget.onLocaleChanged!('en');
                  if (value == 'Spanish') widget.onLocaleChanged!('es');
                  if (value == 'French') widget.onLocaleChanged!('fr');
                }
              },
            ),
          ),

          // Appearance Section
          _buildSectionHeader(loc.appearance, theme),
          SwitchListTile(
            title: Text(
              loc.darkMode,
              style: theme.textTheme.bodyMedium,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleDarkMode(value);
            },
          ),
          ListTile(
            title: Text(
              loc.fontSize,
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
          _buildSectionHeader(loc.preferences, theme),
          ListTile(
            title: Text(
              loc.units,
              style: theme.textTheme.bodyMedium,
            ),
            trailing: DropdownButton<String>(
              value: unitProvider.unitSystem,
              dropdownColor: theme.cardColor,
              items: [
                DropdownMenuItem(value: 'Imperial', child: Text(loc.imperial)),
                DropdownMenuItem(value: 'Metric', child: Text(loc.metric)),
              ],
              onChanged: (value) {
                if (value != null) {
                  unitProvider.setUnitSystem(value);
                }
              },
            ),
          ),

          // Goals Section
          _buildSectionHeader(loc.goals, theme),
          ListTile(
            title: Text(
              loc.weeklyGoal,
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Slider(
              value: goalProvider.weeklyGoal.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              label: '${goalProvider.weeklyGoal} ${loc.workoutsToday}',
              onChanged: (value) {
                goalProvider.setWeeklyGoal(value.toInt());
              },
            ),
          ),

          // About Section
          _buildSectionHeader(loc.about, theme),
          ListTile(
            title: Text(
              loc.appVersion,
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Text(
              '1.0.0',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          ListTile(
            title: Text(
              loc.privacyPolicy,
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