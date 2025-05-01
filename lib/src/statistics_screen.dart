import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/app_toolbar.dart'; // Import AppToolbar
import 'models/exercises_graph.dart';
import 'models/personal_records_graph.dart';

// Convert to StatefulWidget to manage state for the dropdown
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<Map<String, dynamic>> _statisticsFuture;
  List<Map<String, dynamic>> _completedExercises = [];
  int? _selectedExerciseId; // Track the selected exercise ID

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _fetchStatistics();
  }

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final dbHelper = DatabaseHelper();
    final workouts = await dbHelper.getWorkouts();
    final totalWorkouts = workouts.length;

    // Fetch completed exercises details
    final completedExercises = await dbHelper.getCompletedExerciseDetails();
    // Update state for the dropdown
    if (mounted) {
      setState(() {
        _completedExercises = completedExercises;
        // Reset selection if the list changes (optional)
        // _selectedExerciseId = null;
      });
    }

    // Calculate total unique exercises across all workouts
    final Set<String> uniqueExerciseNames = {};
    for (final workout in workouts) {
      final workoutId = workout['id'] as int?; // Ensure workout ID is int?
      if (workoutId != null) {
        final exercises = await dbHelper.getWorkoutExercises(workoutId);
        for (final exercise in exercises) {
          final exerciseName = exercise['exercise_name'] as String?;
          if (exerciseName != null) {
            uniqueExerciseNames.add(exerciseName);
          }
        }
      }
    }
    final totalExercises = uniqueExerciseNames.length;

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
    final totalMinutes = totalTimeSeconds ~/ 60;
    final totalHours = totalMinutes ~/ 60;
    final totalDays = totalHours ~/ 24;

    final displayMinutes = totalMinutes % 60;
    final displayHours = totalHours % 24;

    String totalTime;
    if (totalDays > 0) {
      totalTime = '${totalDays} d ${displayHours.toString().padLeft(2, '0')} h ${displayMinutes.toString().padLeft(2, '0')} m';
    } else if (totalHours > 0) {
      totalTime = '${totalHours} h ${displayMinutes.toString().padLeft(2, '0')} m';
    } else {
      totalTime = '${totalMinutes} m'; // Handle cases less than an hour
    }

    return {
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'totalTime': totalTime, // Use the new formatted string
      'averageTime': averageTime,
    };
  }

  // Modify to accept exerciseId
  void _showGraphModal(BuildContext context, Widget graphWidget, {int? exerciseId}) {
     // Ensure ExercisesGraph receives the exerciseId if provided
     Widget finalGraphWidget = graphWidget;
     if (graphWidget is ExercisesGraph && exerciseId != null) {
       finalGraphWidget = ExercisesGraph(exerciseId: exerciseId);
     } else if (graphWidget is ExercisesGraph && exerciseId == null) {
       // Handle case where ExercisesGraph is expected but no exercise is selected
       // Maybe show a message or disable the tap? For now, just show the default.
       print("Warning: Trying to show ExercisesGraph without a selected exercise.");
       // Or return early:
       // return;
     }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow custom height
      // The builder context inherits the theme, so the modal should use theme colors automatically.
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8, // Use 80% of the available screen height
        child: finalGraphWidget, // Use the potentially updated widget
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context); // Get theme data

    return Scaffold(
      appBar: const AppToolbar(title: 'Statistics'), // Use AppToolbar
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statisticsFuture, // Use the state future
        builder: (context, snapshot) {
          // ... existing loading/error/no data handling ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Use theme's error color or a standard text style for errors
            return Center(child: Text('Error: ${snapshot.error}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available.', style: theme.textTheme.bodyMedium));
          }

          final stats = snapshot.data!;

          return Column(
            children: [
              // Top 25% of the screen with 2x2 cards
              SizedBox(
                height: screenHeight * 0.25,
                child: GridView.count(
                  // ... existing GridView setup ...
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2, // Rectangular cards
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    // Use Card widget which implicitly uses CardTheme from AppTheme
                    Card(
                      // elevation and color are handled by CardTheme
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Workouts',
                            // Use appropriate text styles from the theme
                            style: theme.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['totalWorkouts']}',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), // Example: Use titleLarge
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Exercises',
                            style: theme.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['totalExercises']}',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Time',
                            style: theme.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['totalTime']}',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Average Workout Time',
                            style: theme.textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats['averageTime']}',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  itemCount: 2, // Only Exercises and Personal Records for now
                  itemBuilder: (context, index) {
                    // --- Card for Exercises Graph (index 0) ---
                    if (index == 0) {
                      return GestureDetector(
                        // Only allow tap if an exercise is selected
                        onTap: _selectedExerciseId != null
                            ? () {
                                _showGraphModal(
                                  context,
                                  // Pass exerciseId to the modal function
                                  ExercisesGraph(exerciseId: _selectedExerciseId!),
                                  exerciseId: _selectedExerciseId,
                                );
                              }
                            : null, // Disable onTap if nothing selected
                        child: Card( // Uses CardTheme
                          // elevation and margin are handled by CardTheme, color by CardTheme.color
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Dropdown uses InputDecorationTheme from AppTheme
                                DropdownButtonFormField<int>(
                                  value: _selectedExerciseId,
                                  hint: Text('Select an exercise to view graph', style: theme.inputDecorationTheme.hintStyle),
                                  isExpanded: true,
                                  // decoration uses InputDecorationTheme
                                  decoration: const InputDecoration(
                                    // border and contentPadding are handled by InputDecorationTheme
                                  ),
                                  items: _completedExercises.map((exercise) {
                                    return DropdownMenuItem<int>(
                                      value: exercise['exercise_id'] as int,
                                      child: Text(
                                        exercise['name'] as String? ?? 'Unnamed Exercise',
                                        overflow: TextOverflow.ellipsis,
                                        // Use a default text style that fits dropdown items
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedExerciseId = value;
                                    });
                                  },
                                  // Style the dropdown itself if needed, e.g., icon color
                                  iconEnabledColor: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                const SizedBox(height: 16),
                                // Placeholder/Preview Area
                                if (_selectedExerciseId != null)
                                  Container(
                                    height: 100, // Example height
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                         // Use IconTheme data or specific color from ColorScheme
                                         Icon(Icons.show_chart, size: 40, color: theme.colorScheme.primary),
                                         const SizedBox(height: 8),
                                         Text(
                                          'Tap to view graph for selected exercise',
                                          // Use appropriate text style from theme
                                          style: theme.textTheme.bodySmall,
                                          textAlign: TextAlign.center,
                                         ),
                                      ],
                                    )
                                  )
                                else
                                  Container(
                                    height: 100, // Match height
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Select an exercise from the dropdown above.',
                                      // Use appropriate text style from theme
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    // --- Card for Personal Records Graph (index 1) ---
                    else if (index == 1) {
                      final title = 'Personal Records';
                      return GestureDetector(
                        onTap: () {
                          _showGraphModal(context, const PersonalRecordsGraph());
                        },
                        child: Card( // Uses CardTheme
                          // elevation, margin, color handled by CardTheme
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  title,
                                  // Use appropriate text style from theme
                                  style: theme.textTheme.titleMedium, // Example: Use titleMedium
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                // Keep placeholder image or add specific preview
                                // Consider using an Icon with theme color if appropriate
                                Image.asset(
                                  'assets/images/flutter_logo.png', // Replace with relevant icon/preview
                                  height: 100,
                                  fit: BoxFit.contain,
                                  // Optionally apply theme color filter if it's an icon-like image
                                  // color: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    // --- Placeholder for other potential cards ---
                    else {
                       // You can add more graph cards here if needed
                       return const SizedBox.shrink(); // Or return a placeholder card
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 2, // BottomNavBar should internally use theme
      ),
    );
  }
}
