import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/bottom_nav_bar.dart';
import 'add_exercises_screen.dart'; // Import the new AddExercisesScreen

class StartWorkoutScreen extends StatefulWidget {
  final int templateId;

  const StartWorkoutScreen({Key? key, required this.templateId}) : super(key: key);

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  late Future<List<Map<String, dynamic>>> _exercisesFuture;
  bool _isEditing = false; // Tracks whether the user is in edit mode
  final List<int> _exercisesToRemove = []; // Tracks exercises marked for removal
  late Future<int> _templatePremadeStatus;

  @override
  void initState() {
    super.initState();
    _templatePremadeStatus = _fetchTemplatePremadeStatus();
    _exercisesFuture = _fetchExercises();
  }

  Future<List<Map<String, dynamic>>> _fetchExercises() async {
    return await DatabaseHelper().getExercisesByTemplateId(widget.templateId);
  }

  Future<int> _fetchTemplatePremadeStatus() async {
    return await DatabaseHelper().getTemplatePremadeStatus(widget.templateId);
  }

  Future<void> _removeExercisesFromTemplate() async {
    final dbHelper = DatabaseHelper();
    for (final exerciseId in _exercisesToRemove) {
      await dbHelper.deleteExerciseFromTemplate(widget.templateId, exerciseId);
    }
    setState(() {
      _exercisesFuture = _fetchExercises(); // Refresh the list after deletion
      _exercisesToRemove.clear(); // Clear the list of removed exercises
    });
  }

  Future<void> _deleteTemplate(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    try {
      await dbHelper.deleteTemplate(widget.templateId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Template deleted successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(context, true); // Pass true to indicate successful deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete template: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
        backgroundColor: theme.appBarTheme.backgroundColor, // Use theme app bar color
        foregroundColor: theme.appBarTheme.foregroundColor, // Use theme app bar text color
        actions: [
          FutureBuilder<int>(
            future: _templatePremadeStatus,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink(); // Show nothing while loading
              }

              if (snapshot.hasData && snapshot.data == 0) {
                // Show edit and delete options only if template_premade is 0
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Template'),
                              content: const Text('Are you sure you want to delete this template?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await _deleteTemplate(context);
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_isEditing) {
                          await _removeExercisesFromTemplate();
                        }
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      child: Text(
                        _isEditing ? 'Done' : 'Edit',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary, // Ensure consistent text color
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink(); // Hide options if template_premade is 1
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable list of exercises (90% of the screen height)
          Expanded(
            flex: 9,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _exercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading exercises.',
                      style: theme.textTheme.bodyLarge, // Use theme text style
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No exercises found.',
                      style: theme.textTheme.bodyLarge, // Use theme text style
                    ),
                  );
                } else {
                  final exercises = snapshot.data!;
                  return ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final exerciseId = exercise['exercise_id'];
                      final isMarkedForRemoval = _exercisesToRemove.contains(exerciseId);

                      return ListTile(

                        title: Text(exercise['name'] ?? 'Unknown Exercise'),
                        subtitle: Text(exercise['Description'] ?? 'No description available'),
                        trailing: _isEditing
                            ? IconButton(
                                icon: Icon(
                                  isMarkedForRemoval ? Icons.add : Icons.remove,
                                  color: isMarkedForRemoval ? Colors.green : Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isMarkedForRemoval) {
                                      _exercisesToRemove.remove(exerciseId);
                                    } else {
                                      _exercisesToRemove.add(exerciseId);
                                    }
                                  });
                                },
                              )
                            : null,
                      );
                    },
                  );
                }
              },
            ),
          ),
          // Bottom section with "Add Exercises" button in edit mode
          if (_isEditing)
            Expanded(
              flex: 1,
              child: Container(
                color: theme.colorScheme.surfaceVariant, // Use theme surface variant color
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Navigate to AddExercisesScreen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExercisesScreen(templateId: widget.templateId),
                        ),
                      );

                      // Refresh the exercises list if new exercises were added
                      if (result == true) {
                        setState(() {
                          _exercisesFuture = _fetchExercises();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary, // Use theme primary color
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add Exercises',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary, // Use theme onPrimary color
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Bottom section with "Start Workout" button (10% of the screen height)
          if (!_isEditing)
            Expanded(
              flex: 1,
              child: Container(
                color: theme.colorScheme.surfaceVariant, // Use theme surface variant color
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Ensure exercises are fetched and passed correctly
                      _fetchExercises().then((exercises) {
                        Navigator.pushNamed(
                          context,
                          '/in_progress_workout',
                          arguments: {
                            'template_id': widget.templateId, // Pass the template_id
                            'exercises': exercises, // Pass the exercises list
                          },
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary, // Use theme primary color
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Start Workout',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary, // Use theme onPrimary color
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0, // Set the appropriate index for this screen
      ),
    );
  }
}