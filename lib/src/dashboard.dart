import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'providers/goal_provider.dart'; // Import GoalProvider
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'start_workout_screen.dart';
import 'create_workout_screen.dart';
import 'widgets/dashboard_template_card.dart';
import 'widgets/goal_progress_ring.dart'; // Import the new ring widget
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<List<Map<String, dynamic>>> _templatesFuture;
  late Future<Map<String, int>> _goalDataFuture; // Future for goal data

  @override
  void initState() {
    super.initState();
    _templatesFuture = _fetchTemplates();
    _goalDataFuture = _fetchGoalData(); // Fetch goal data on init
  }

  Future<List<Map<String, dynamic>>> _fetchTemplates() async {
    return await DatabaseHelper().getTemplates();
  }

  // New method to fetch goal and workout completion data
  Future<Map<String, int>> _fetchGoalData() async {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    // Ensure goal preferences are loaded if not already
    // You might want to call loadPreferences earlier in your app initialization
    // await goalProvider.loadPreferences();

    final dbHelper = DatabaseHelper();
    final weeklyGoal = goalProvider.weeklyGoal;
    final weeklyCompleted = await dbHelper.getWorkoutsCompletedThisWeek();
    final monthlyCompleted = await dbHelper.getWorkoutsCompletedThisMonth();
    final monthlyGoal = weeklyGoal * 4; // Simple monthly goal calculation

    return {
      'weeklyGoal': weeklyGoal,
      'weeklyCompleted': weeklyCompleted,
      'monthlyGoal': monthlyGoal,
      'monthlyCompleted': monthlyCompleted,
    };
  }

  void _refreshData() {
    setState(() {
      _templatesFuture = _fetchTemplates();
      _goalDataFuture = _fetchGoalData(); // Re-fetch goal data as well
    });
  }

  void _showStartWorkoutScreen(BuildContext context, int templateId) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          widthFactor: 0.9,
          child: StartWorkoutScreen(templateId: templateId),
        );
      },
    );

    if (result == true) {
      _refreshData(); // Refresh all data
    }
  }

  void _navigateToCreateWorkoutScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateWorkoutScreen()),
    );

    if (result == true) {
      _refreshData(); // Refresh all data
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppToolbar(title: loc.dashboardTitle),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Top Section (25% of available height) - Now with Goal Rings
              Expanded(
                flex: 1, // Adjust flex as needed
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  child: FutureBuilder<Map<String, int>>(
                    future: _goalDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text(loc.errorLoadingGoals(snapshot.error.toString())));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Center(child: Text(loc.noGoalDataFound));
                      } else {
                        final goalData = snapshot.data!;
                        final ringSize = constraints.maxHeight * 0.25 * 0.6; // Example size calculation

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GoalProgressRing(
                              currentValue: goalData['weeklyCompleted']!,
                              goalValue: goalData['weeklyGoal']!,
                              label: loc.weekly,
                              size: ringSize,
                            ),
                            GoalProgressRing(
                              currentValue: goalData['monthlyCompleted']!,
                              goalValue: goalData['monthlyGoal']!,
                              label: loc.monthly,
                              size: ringSize,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
              // Middle Section (Templates Grid)
              Expanded(
                flex: 3, // Adjust flex as needed
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _templatesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text(loc.errorLoadingTemplates));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text(loc.noTemplatesFound));
                      } else {
                        final templates = snapshot.data!;
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1 / 1.25,
                          ),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            return DashboardTemplateCard(
                              templateName: template['template_name'] ?? loc.unknownTemplate,
                              onTap: () {
                                _showStartWorkoutScreen(context, template['template_id']);
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
              // Bottom Section (Create Button)
              Expanded(
                flex: 1, // Adjust flex as needed
                child: Container(
                  color: Theme.of(context).colorScheme.background, // Use background color from theme
                  child: Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.7,
                      height: constraints.maxHeight * 0.15 * 0.4, // Adjusted height calculation
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateToCreateWorkoutScreen(context); // Navigate to CreateWorkoutScreen
                        },
                        child: Text(
                          loc.createNewWorkout,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0, // Dashboard tab
      ),
    );
  }
}