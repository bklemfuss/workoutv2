import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/unit_provider.dart';
import 'services/database_helper.dart'; // Import DatabaseHelper
import 'widgets/exercise_input_card.dart';
import 'theme/colors.dart'; // Import AppColors

class InProgressWorkoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final int templateId;

  const InProgressWorkoutScreen({Key? key, required this.exercises, required this.templateId})
      : super(key: key);

  @override
  State<InProgressWorkoutScreen> createState() => _InProgressWorkoutScreenState();
}

class _InProgressWorkoutScreenState extends State<InProgressWorkoutScreen> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  final Map<int, List<Map<String, dynamic>>> _exercisesData = {};
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _initializeExerciseData(); // Call async initialization
    _startTimer();
  }

  // New async method to initialize exercise data
  Future<void> _initializeExerciseData() async {
    final dbHelper = DatabaseHelper();
    for (var exercise in widget.exercises) {
      final exerciseId = exercise['exercise_id'] as int;
      int setCount = await dbHelper.getLastWorkoutSetsCountForExercise(
        widget.templateId,
        exerciseId,
      );

      // Default to 1 set if no previous data or 0 sets recorded
      if (setCount <= 0) {
        setCount = 1;
      }

      // Initialize sets with default values including isChecked
      _exercisesData[exerciseId] = List.generate(
        setCount,
        (_) => {'reps': 0, 'weight': 0.0, 'isChecked': false}, // Add isChecked
      );
    }
    // Update state after fetching data
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Ensure proper disposal of controllers or focus nodes if used
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

    void _handleSetsChanged(int exerciseId, List<Map<String, dynamic>> sets) {
    setState(() {
      _exercisesData[exerciseId] = sets;
    });
  }

  Future<void> _finishWorkout(BuildContext context) async {
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database; // Await the database getter

  try {
    // Step 1: Create a new workout
    final workoutId =
        await dbHelper.createWorkout(widget.templateId, 1); // Use user_id = 1 for now

    // **Use a transaction to ensure data consistency.**
    await db.transaction((txn) async {
      // Step 2: Create workout exercises for CHECKED sets only
      for (var exerciseId in _exercisesData.keys) {
        final allSets = _exercisesData[exerciseId]!; // Get all sets for this exercise
        // Filter sets where 'isChecked' is true
        final checkedSets = allSets.where((set) => set['isChecked'] == true).toList();

        for (var set in checkedSets) { // Iterate only over checked sets
          await dbHelper.createWorkoutExercise(
            txn, // Pass the transaction
            workoutId,
            exerciseId,
            set['reps'] ?? 0,
            set['weight'] ?? 0.0,
          );
        }
      }
    });

    // Step 3: Save the workout timer in the database
    await dbHelper.updateWorkoutTimer(workoutId, _elapsedSeconds);

    // Step 4: Navigate to the PostWorkoutScreen using named route
    Navigator.pushReplacementNamed(
      context,
      '/workout_summary',
      arguments: workoutId,
    );
  } catch (e) {
    //  Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save workout: $e'), backgroundColor: Colors.red),
    );
  }
}

  Future<void> _discardWorkout(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the theme
    final colorScheme = theme.colorScheme; // Get the color scheme
    final textTheme = theme.textTheme; // Get the text theme

    // Ensure no parent widget intercepts touch events
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        appBar: AppBar(title: const Text('In Progress Workout')), // Uses AppBarTheme
        body: _isLoading // Show loading indicator while fetching data
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                    // Use a theme color, maybe secondary or a custom one if needed
                    color: colorScheme.secondaryContainer, // Example: Using secondaryContainer
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(_elapsedSeconds),
                          // Use a text theme style
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<int>(
                              context: context,
                              builder: (context) {
                                // AlertDialog will use DialogTheme from AppTheme
                                return AlertDialog(
                                  title: const Text('Finish Workout'),
                                  content: const Text('What would you like to do with this workout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 0);
                                      },
                                      // TextButton uses TextButtonTheme
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 1);
                                      },
                                      child: const Text('Finish and Save'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 2);
                                      },
                                      // Consider a different style for destructive actions if needed
                                      child: Text(
                                        'Finish and Discard',
                                        style: TextStyle(color: colorScheme.error), // Use error color for discard
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == 1) {
                              await _finishWorkout(context);
                            } else if (confirm == 2) {
                              await _discardWorkout(context);
                            } else {
                              debugPrint('No action taken.');
                            }
                          },
                          // Use ElevatedButtonTheme, potentially override specific properties if needed
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success, // Use theme success color
                            foregroundColor: AppColors.onSuccess, // Use theme color for text on success
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.height * 0.01,
                              horizontal: MediaQuery.of(context).size.width * 0.05,
                            ),
                            // Use text style from theme if possible, or define explicitly if needed
                            textStyle: textTheme.labelLarge?.copyWith(fontSize: 14), // Example using labelLarge
                          ),
                          child: const Text(
                            'Finish Workout',
                            // Style is now mostly handled by ElevatedButton.styleFrom
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = widget.exercises[index];
                        final exerciseId = exercise['exercise_id'] as int;
                        // Pass the initialized sets to the card
                        // Ensure _exercisesData has the entry before building the card
                        if (_exercisesData.containsKey(exerciseId)) {
                           // Create a copy of the exercise map and add the sets data
                           final exerciseWithSets = Map<String, dynamic>.from(exercise);
                           // Make sure to pass the sets with the 'isChecked' field
                           exerciseWithSets['sets'] = _exercisesData[exerciseId];

                           return ExerciseInputCard(
                             exercise: exerciseWithSets, // Pass the map with sets
                             onSetsChanged: _handleSetsChanged,
                           );
                        } else {
                          // Handle case where data might not be ready (though _isLoading should prevent this)
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  Padding( // Add some padding
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Weight: ${Provider.of<UnitProvider>(context).unitSystem == 'Metric' ? 'kg' : 'lbs'}',
                        // Use a text theme style
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
