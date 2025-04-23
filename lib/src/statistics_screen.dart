import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/bottom_nav_bar.dart';
import 'theme/app_theme.dart'; // Import AppTheme
import 'models/exercises_graph.dart'; // Import ExercisesGraph
import 'models/personal_records_graph.dart'; // Import PersonalRecordsGraph

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final dbHelper = DatabaseHelper();
    final totalWorkouts = (await dbHelper.getWorkouts()).length;
    final totalExercises = (await dbHelper.getWorkoutExercises(0)).length; // Fetch all exercises
    final totalTimeSeconds = (await dbHelper.getWorkouts())
        .fold<int>(0, (sum, workout) => sum + (workout['workout_timer'] as int));

    // Format total time
    final hours = totalTimeSeconds ~/ 3600;
    final minutes = (totalTimeSeconds % 3600) ~/ 60;
    final totalTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'totalTime': totalTime,
    };
  }

  void _showGraphModal(BuildContext context, Widget graphWidget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow custom height
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8, // Use 80% of the available screen height
        child: graphWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Use AppTheme
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available.'));
          }

          final stats = snapshot.data!;

          return Column(
            children: [
              // Top 25% of the screen with 2x2 cards
              SizedBox(
                height: screenHeight * 0.25,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2, // Rectangular cards
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    Card(
                      elevation: 4,
                      color: Theme.of(context).cardColor, // Use AppTheme
                      child: Center(
                        child: Text(
                          'Total Workouts: ${stats['totalWorkouts']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      color: Theme.of(context).cardColor, // Use AppTheme
                      child: Center(
                        child: Text(
                          'Total Exercises: ${stats['totalExercises']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      color: Theme.of(context).cardColor, // Use AppTheme
                      child: Center(
                        child: Text(
                          'Total Time: ${stats['totalTime']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      color: Theme.of(context).cardColor, // Use AppTheme
                      child: const Center(
                        child: Text(
                          'Placeholder',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Remaining 75% of the screen with scrollable list of graph cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: 10, // Placeholder for 10 graph cards
                  itemBuilder: (context, index) {
                    final title = index == 0
                        ? 'Exercises'
                        : index == 1
                            ? 'Personal Records'
                            : 'Placeholder';

                    return GestureDetector(
                      onTap: () {
                        if (index == 0) {
                          _showGraphModal(context, const ExercisesGraph());
                        } else if (index == 1) {
                          _showGraphModal(context, const PersonalRecordsGraph());
                        }
                      },
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: Theme.of(context).cardColor, // Use AppTheme
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Image.asset(
                                'assets/images/flutter_logo.png',
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 2,
      ),
    );
  }
}
