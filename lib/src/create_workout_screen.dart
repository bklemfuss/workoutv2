import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/exercise_details_dialog.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController workoutNameController = TextEditingController(); // Controller for workout name
  String selectedMuscleGroup = 'All';
  List<Map<String, dynamic>> allExercises = []; // Original unfiltered list
  List<Map<String, dynamic>> exercises = []; // Filtered list
  List<int> selectedExerciseIds = [];
  bool showBodyweightOnly = false; // New state for radio button

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises({String? muscleGroup}) async {
    final dbHelper = DatabaseHelper();
    final fetchedExercises = await dbHelper.getExercisesByMuscleGroup(muscleGroup);
    setState(() {
      allExercises = fetchedExercises; // Store the original data
      _applyEquipmentFilter(); // Apply equipment filter after fetching
    });
  }

  void _applyEquipmentFilter() {
    // Filter by equipment and search query
    List<Map<String, dynamic>> filtered = List.from(allExercises);
    if (showBodyweightOnly) {
      filtered = filtered.where((e) => e['equipment'] == 0).toList();
    }
    final query = searchController.text.trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((exercise) =>
              exercise['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    exercises = filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _applyEquipmentFilter();
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
                    SnackBar(
                      content: const Text('Workout name cannot be empty!'),
                      backgroundColor: Theme.of(context).colorScheme.error, // Use theme error color
                    ),
                  );
                } 
                else {
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
                        backgroundColor: Theme.of(context).colorScheme.primary, // Use theme primary color
                        behavior: SnackBarBehavior.floating, // Make it float
                        margin: const EdgeInsets.only(top: 16, left: 16, right: 16), // Position at the top
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
                        backgroundColor: Theme.of(context).colorScheme.error, // Use theme error color
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

  void _showCreateCustomExerciseDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedMuscleGroup = 'All';
    bool requiresEquipment = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Custom Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    hintText: 'Enter exercise name',
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter exercise description',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: selectedMuscleGroup,
                  items: ['All', 'Chest', 'Back', 'Legs', 'Arms', 'Core']
                      .map((group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedMuscleGroup = value!;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Muscle Group',
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: requiresEquipment,
                      onChanged: (value) {
                        requiresEquipment = value!;
                      },
                    ),
                    const Text('Requires Equipment'),
                  ],
                ),
              ],
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
                final exerciseName = nameController.text.trim();
                final exerciseDescription = descriptionController.text.trim();

                if (exerciseName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Exercise name cannot be empty!'),
                      backgroundColor: Theme.of(context).colorScheme.error, // Use theme error color
                    ),
                  );
                  return;
                }

                // Save the custom exercise to the database
                final dbHelper = DatabaseHelper();
                await dbHelper.addCustomExercise(
                  name: exerciseName,
                  description: exerciseDescription,
                  muscleGroup: selectedMuscleGroup,
                  requiresEquipment: requiresEquipment,
                );

                // Refresh the exercise list
                _fetchExercises();

                // Close the dialog
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar( // Removed const
                    content: const Text('Custom exercise created successfully!'),
                    backgroundColor: Theme.of(context).colorScheme.primary, // Use theme primary color
                  ),
                );
              },
              child: const Text('Save'),
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
                // Equipment switch
                SizedBox(
                  width: 140,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Bodyweight',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: showBodyweightOnly,
                    onChanged: (val) {
                      setState(() {
                        showBodyweightOnly = val;
                        _applyEquipmentFilter();
                      });
                    },
                  ),
                ),
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
                final isSelected = selectedExerciseIds.contains(exercise['exercise_id']); // Check if the exercise is selected

                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  elevation: 4,
                  color: theme.cardColor, // Use cardColor from AppTheme
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ExerciseDetailsDialog(exercise: exercise),
                      );
                    },
                    title: Text(
                      exercise['name'] ?? 'Unknown Exercise',
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      exercise['Description'] ?? 'No description available',
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: Icon(isSelected ? Icons.remove : Icons.add), // Toggle icon
                      color: theme.primaryColor, // Use primaryColor from AppTheme
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            // If already selected, remove from the list
                            selectedExerciseIds.remove(exercise['exercise_id']);
                          } else {
                            // If not selected, add to the list
                            selectedExerciseIds.add(exercise['exercise_id']);
                          }
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusted padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible( // Wrap with Flexible
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error, // Cancel button color
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Optional: Adjust button padding
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8), // Add spacing between buttons
                Flexible( // Wrap with Flexible
                  child: ElevatedButton(
                    onPressed: () {
                      _showCreateCustomExerciseDialog(); // Show the custom exercise dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary, // Create Custom Exercise button color
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Optional: Adjust button padding
                    ),
                    child: const Text('Custom Exercise', textAlign: TextAlign.center), // Adjust text if needed
                  ),
                ),
                const SizedBox(width: 8), // Add spacing between buttons
                Flexible( // Wrap with Flexible
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedExerciseIds.isEmpty) {
                        // Show an error if no exercises are selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Can't create an empty workout template!"),
                            backgroundColor: Theme.of(context).colorScheme.error, // Use theme error color
                          ),
                        );
                      } else {
                        _showSaveDialog(); // Show the save dialog if exercises are selected
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary, // Save button color
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Optional: Adjust button padding
                    ),
                    child: const Text('Save'),
                  ),
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