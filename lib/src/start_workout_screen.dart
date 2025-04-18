import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/bottom_nav_bar.dart';

class StartWorkoutScreen extends StatelessWidget {
  final int templateId;

  const StartWorkoutScreen({Key? key, required this.templateId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchExercises() async {
    return await DatabaseHelper().getExercisesByTemplateId(templateId);
  }

  Future<void> _deleteTemplate(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    try {
      await dbHelper.deleteTemplate(templateId);
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
        ],
      ),
      body: Column(
        children: [
          // Scrollable list of exercises (90% of the screen height)
          Expanded(
            flex: 9,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchExercises(),
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
                      return ListTile(
                        title: Text(
                          exercise['name'] ?? 'Unknown Exercise',
                          style: theme.textTheme.bodyLarge, // Use theme text style
                        ),
                        subtitle: Text(
                          exercise['Description'] ?? 'No description available',
                          style: theme.textTheme.bodyMedium, // Use theme text style
                        ),
                        onTap: () {
                          // Add functionality for tapping an exercise if needed
                        },
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
                          'template_id': templateId, // Pass the template_id
                          'exercises': exercises,    // Pass the exercises list
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