import 'package:flutter/material.dart';
import 'services/database_helper.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController workoutNameController = TextEditingController(); // Controller for workout name
  String selectedMuscleGroup = 'All';
  List<Map<String, dynamic>> exercises = [];
  List<int> selectedExerciseIds = [];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises({String? muscleGroup}) async {
    final dbHelper = DatabaseHelper();
    final fetchedExercises = await dbHelper.getExercisesByMuscleGroup(muscleGroup);
    setState(() {
      exercises = fetchedExercises;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      exercises = exercises
          .where((exercise) =>
              exercise['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Workout'),
          content: TextField(
            controller: workoutNameController,
            decoration: const InputDecoration(
              hintText: 'Enter workout name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final workoutName = workoutNameController.text.trim();

                if (workoutName.isEmpty) {
                  // Show an error if the workout name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Workout name cannot be empty!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (selectedExerciseIds.isEmpty) {
                  // Show an error if no exercises are selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Can't create an empty workout template!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  try {
                    // Save the workout template and exercises
                    final dbHelper = DatabaseHelper();
                    await dbHelper.saveWorkoutTemplate(
                      workoutName: workoutName,
                      exerciseIds: selectedExerciseIds,
                    );

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Workout "$workoutName" saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Clear the inputs
                    workoutNameController.clear();
                    selectedExerciseIds.clear();

                    // Close the dialog and return to the dashboard with a result
                    Navigator.pop(context); // Close the dialog
                    Navigator.pop(context, true); // Return to the dashboard with a success result
                  } catch (e) {
                    // Show an error if saving fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save workout: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Workout'),
      ),
      body: Column(
        children: [
          // Search Bar (Top 10%)
          Container(
            height: screenHeight * 0.1,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
              ),
            ),
          ),
          // Filter Row (5%)
          Container(
            height: screenHeight * 0.05,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter by Muscle Group:'),
                DropdownButton<String>(
                  value: selectedMuscleGroup,
                  items: ['All', 'Chest', 'Back', 'Legs', 'Arms', 'Core']
                      .map((group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMuscleGroup = value!;
                    });
                    _fetchExercises(
                        muscleGroup: value == 'All' ? null : value);
                  },
                ),
              ],
            ),
          ),
          // Exercise List (Remaining 75%)
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  elevation: 4,
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      exercise['name'],
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          selectedExerciseIds.add(exercise['exercise_id']);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom Buttons (10%)
          Container(
            height: screenHeight * 0.1,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Cancel button color
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _showSaveDialog, // Show the save dialog
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Save button color
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    workoutNameController.dispose(); // Dispose the workout name controller
    super.dispose();
  }
}