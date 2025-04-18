import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/bottom_nav_bar.dart';

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

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _fetchExercises();
  }

  Future<List<Map<String, dynamic>>> _fetchExercises() async {
    return await DatabaseHelper().getExercisesByTemplateId(widget.templateId);
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
        const SnackBar(
          content: Text('Template deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Pass true to indicate successful deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete template: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Workout'),
        actions: [
          // Trash can icon to delete the template
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
                        onPressed: () => Navigator.pop(context, false), // Cancel
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true), // Confirm
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
          // Edit/Done toggle button
          TextButton(
            onPressed: () async {
              if (_isEditing) {
                // If toggling back to "Done", remove exercises from the template
                await _removeExercisesFromTemplate();
              }
              setState(() {
                _isEditing = !_isEditing; // Toggle edit mode
              });
            },
            child: Text(
              _isEditing ? 'Done' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
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
                  return const Center(child: Text('Error loading exercises.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No exercises found.'));
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
          // Bottom section with "Start Workout" button (10% of the screen height)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue[100], // Optional background color
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
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Workout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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