import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/exercise_details_dialog.dart'; // Import ExerciseDetailsDialog

class AddExercisesScreen extends StatefulWidget {
  final int templateId;

  const AddExercisesScreen({Key? key, required this.templateId}) : super(key: key);

  @override
  State<AddExercisesScreen> createState() => _AddExercisesScreenState();
}

class _AddExercisesScreenState extends State<AddExercisesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Use instance for multiple calls
  late Future<void> _initExercisesFuture; // Future for initial loading
  List<Map<String, dynamic>> _allExercises = []; // Holds all available exercises
  List<Map<String, dynamic>> _filteredExercises = []; // Holds exercises after filtering/searching
  final List<int> _selectedExercises = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedMuscleGroup = 'All';

  @override
  void initState() {
    super.initState();
    _initExercisesFuture = _initializeExercises();
    _searchController.addListener(_onSearchChanged); // Add listener for search
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // Remove listener
    _searchController.dispose(); // Dispose controller
    super.dispose();
  }

  Future<void> _initializeExercises() async {
    // Fetch all exercises not in the template, including muscle group names
    _allExercises = await _dbHelper.getExercisesNotInTemplateWithMuscleGroup(widget.templateId);
    _applyFilters(); // Apply initial filters (which is 'All' and empty search)
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredExercises = _allExercises.where((exercise) {
        final nameMatches = exercise['name']?.toLowerCase().contains(query) ?? false;
        final muscleGroupMatches = _selectedMuscleGroup == 'All' ||
            exercise['muscle_group'] == _selectedMuscleGroup; // Assuming 'muscle_group' key exists
        return nameMatches && muscleGroupMatches;
      }).toList();
    });
  }

  void _onSearchChanged() {
    _applyFilters(); // Re-apply filters when search text changes
  }

  Future<void> _addExercisesToTemplate() async {
    for (final exerciseId in _selectedExercises) {
      await _dbHelper.addExerciseToTemplate(widget.templateId, exerciseId);
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
      body: FutureBuilder<void>(
        future: _initExercisesFuture, // Wait for initial fetch
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
          } else {
            // Main content column
            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.01,
                  ),
                  child: TextField(
                    controller: _searchController,
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
                // Filter Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter by Muscle Group:'),
                      DropdownButton<String>(
                        value: _selectedMuscleGroup,
                        items: ['All', 'Chest', 'Back', 'Legs', 'Arms', 'Core'] // Add other groups if needed
                            .map((group) => DropdownMenuItem(
                                  value: group,
                                  child: Text(group),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMuscleGroup = value;
                            });
                            _applyFilters(); // Re-apply filters when group changes
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Exercise List
                Expanded(
                  child: _filteredExercises.isEmpty
                      ? Center(
                          child: Text(
                            'No exercises match your criteria.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredExercises.length, // Use filtered list
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index]; // Use filtered list
                            final exerciseId = exercise['exercise_id'];
                            final isSelected = _selectedExercises.contains(exerciseId);

                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.005, // Reduced vertical margin
                              ),
                              elevation: 4,
                              color: theme.cardColor, // Use cardColor from the theme
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                onTap: () { // Add onTap to show details
                                  showDialog(
                                    context: context,
                                    builder: (context) => ExerciseDetailsDialog(exercise: exercise),
                                  );
                                },
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
                        ),
                ),
              ],
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