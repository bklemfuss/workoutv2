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
    final workouts = await dbHelper.getWorkouts();
    final totalWorkouts = workouts.length;
    // Assuming getWorkoutExercises(0) fetches all exercises is incorrect.
    // This needs adjustment if you want *all* exercises across *all* workouts.
    // For now, let's assume you want exercises from a specific workout (e.g., workout_id 0, which might not exist)
    // or perhaps you intended to count all exercise *types*?
    // Clarification needed on what "Total Exercises" should represent.
    // Fetching exercises for workout_id 0 as per original code:
    final totalExercises = (await dbHelper.getWorkoutExercises(0)).length;

    final totalTimeSeconds = workouts.fold<int>(0, (sum, workout) {
      final timerValue = workout['workout_timer'];
      // Add null check and default to 0 if null
      return sum + (timerValue is int ? timerValue : 0);
    });

    // Calculate average workout time
    final averageTimeSeconds = totalWorkouts > 0 ? totalTimeSeconds ~/ totalWorkouts : 0;
    final averageTime = averageTimeSeconds > 3599
        ? '${(averageTimeSeconds ~/ 3600).toString().padLeft(2, '0')}:${((averageTimeSeconds % 3600) ~/ 60).toString().padLeft(2, '0')}'
        : '${(averageTimeSeconds ~/ 60).toString()} min';

    // Format total time
    final hours = totalTimeSeconds ~/ 3600;
    final minutes = (totalTimeSeconds % 3600) ~/ 60;
    final totalTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'totalTime': totalTime,
      'averageTime': averageTime,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Workouts',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['totalWorkouts']}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 4,
                      color: Theme.of(context).cardColor, // Use AppTheme
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Exercises',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['totalExercises']}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 4,
                      color: Theme.of(context).cardColor, // Use AppTheme
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Time',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['totalTime']}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 4,
                      color: Theme.of(context).cardColor, // Use AppTheme
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Average Workout Time',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['averageTime']}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
