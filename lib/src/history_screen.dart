import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';
import 'theme/colors.dart'; // Import AppColors for custom colors

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchWorkouts() async {
    return await DatabaseHelper().getWorkoutsWithDetails();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme

    return Scaffold(
      appBar: const AppToolbar(title: 'History'),
      body: Column(
        children: [
          // Top Section (10% of the screen height)
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            color: theme.appBarTheme.backgroundColor, // Use theme's app bar background color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    size: 28,
                    color: AppColors.textPrimary, // Use primary text color
                  ),
                  onPressed: () {
                    // Add functionality for calendar icon if needed
                  },
                ),
              ],
            ),
          ),
          // Remaining Section (90% of the screen height)
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchWorkouts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading workouts.',
                      style: theme.textTheme.bodyLarge, // Use theme's text style
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No workouts found.',
                      style: theme.textTheme.bodyLarge, // Use theme's text style
                    ),
                  );
                } else {
                  final workouts = snapshot.data!;
                  return ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: AppColors.secondary, // Use secondary color for cards
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            workout['template_name'] ?? 'Unknown Template',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ), // Use theme's text style
                          ),
                          subtitle: Text(
                            'Date: ${workout['date']}\nUser: ${workout['user_name'] ?? 'Unknown User'}',
                            style: theme.textTheme.bodyMedium, // Use theme's text style
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            // Navigate to workout summary screen
                            Navigator.pushNamed(
                              context,
                              '/workout_summary',
                              arguments: workout['workout_id'],
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const FloatingStartNewWorkoutButton(), // Use the custom FAB widget
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}

class WorkoutSummaryScreen extends StatelessWidget {
  final int workoutId;

  const WorkoutSummaryScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Summary (ID: $workoutId)'),
      ),
      body: Center(
        child: Text(
          'Details for Workout ID: $workoutId',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}