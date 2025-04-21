import 'package:flutter/material.dart';
import 'services/database_helper.dart';

class AddExercisesScreen extends StatefulWidget {
  final int templateId;

  const AddExercisesScreen({Key? key, required this.templateId}) : super(key: key);

  @override
  State<AddExercisesScreen> createState() => _AddExercisesScreenState();
}

class _AddExercisesScreenState extends State<AddExercisesScreen> {
  late Future<List<Map<String, dynamic>>> _exercisesFuture;
  final List<int> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _fetchAvailableExercises();
  }

  Future<List<Map<String, dynamic>>> _fetchAvailableExercises() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getExercisesNotInTemplate(widget.templateId);
  }

  Future<void> _addExercisesToTemplate() async {
    final dbHelper = DatabaseHelper();
    for (final exerciseId in _selectedExercises) {
      await dbHelper.addExerciseToTemplate(widget.templateId, exerciseId);
    }
    Navigator.pop(context, true); // Return true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercises'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading exercises.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No exercises available to add.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          } else {
            final exercises = snapshot.data!;
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final exerciseId = exercise['exercise_id'];
                final isSelected = _selectedExercises.contains(exerciseId);

                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  elevation: 4,
                  color: theme.cardColor, // Use cardColor from the theme
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      exercise['name'] ?? 'Unknown Exercise',
                      style: theme.textTheme.bodyLarge, // Use textTheme from the theme
                    ),
                    subtitle: Text(
                      exercise['Description'] ?? 'No description available',
                      style: theme.textTheme.bodyMedium, // Use textTheme from the theme
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isSelected ? Icons.remove : Icons.add,
                        color: isSelected ? Colors.red : Colors.green,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            _selectedExercises.remove(exerciseId);
                          } else {
                            _selectedExercises.add(exerciseId);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExercisesToTemplate,
        label: const Text('Save'),
        icon: const Icon(Icons.save),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}