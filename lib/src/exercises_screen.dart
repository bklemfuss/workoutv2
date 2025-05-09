import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/exercise_details_dialog.dart';
import 'widgets/create_exercise_dialog.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  String _searchQuery = '';
  String _selectedMuscleGroup = 'All';
  bool _bodyweightOnly = false; // Add bodyweight filter

  final List<String> _muscleGroupOptions = ['All', 'Chest', 'Back', 'Legs', 'Arms', 'Core'];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    // Use the new method from DatabaseHelper to get exercises with muscle group info
    final db = DatabaseHelper();
    final allExercises = await db.getAllExercisesWithMuscleGroup();
    setState(() {
      _exercises = allExercises;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      // Debug: print all muscle group values in _exercises
      print('DEBUG: All muscle_group values in _exercises:');
      for (final ex in _exercises) {
        print('  exercise_id=${ex['exercise_id']} name=${ex['name']} muscle_group=${ex['muscle_group']}');
      }
      print('DEBUG: _selectedMuscleGroup=$_selectedMuscleGroup');

      _filteredExercises = _exercises.where((exercise) {
        final matchesSearch = exercise['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchesMuscleGroup = _selectedMuscleGroup == 'All'
            ? true
            : (exercise['muscle_group'] == _selectedMuscleGroup);
        if (!matchesMuscleGroup) {
          print('DEBUG: Filtered out by muscle_group: exercise_id=${exercise['exercise_id']} muscle_group=${exercise['muscle_group']}');
        }
        final matchesBodyweight = !_bodyweightOnly
            ? true
            : (exercise['equipment'] == 0 || exercise['equipment'] == false || exercise['equipment'] == '0');
        if (!matchesBodyweight) {
          print('DEBUG: Filtered out by bodyweight: exercise_id=${exercise['exercise_id']} equipment=${exercise['equipment']}');
        }
        return matchesSearch && matchesMuscleGroup && matchesBodyweight;
      }).toList();

      print('DEBUG: Filtered exercises count: ${_filteredExercises.length}');
    });
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _applyFilters();
  }

  void _onMuscleGroupChanged(String? value) {
    if (value != null) {
      _selectedMuscleGroup = value;
      _applyFilters();
    }
  }

  void _onBodyweightSwitchChanged(bool value) {
    setState(() {
      _bodyweightOnly = value;
      _applyFilters();
    });
  }

  void _showExerciseDetailsDialog(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) {
        return ExerciseDetailsDialog(exercise: exercise);
      },
    );
  }

  void _showCreateExerciseDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateExerciseDialog(
        onExerciseCreated: () {
          _fetchExercises();
        },
      ),
    );
    if (result == true) {
      _fetchExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppToolbar(title: 'Exercises'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter by Muscle Group:'),
                DropdownButton<String>(
                  value: _selectedMuscleGroup,
                  items: _muscleGroupOptions
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: _onMuscleGroupChanged,
                ),
                Row(
                  children: [
                    const Text('Bodyweight Only'),
                    Switch(
                      value: _bodyweightOnly,
                      onChanged: _onBodyweightSwitchChanged,
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredExercises.isEmpty
                ? const Center(child: Text('No exercises found.'))
                : ListView.builder(
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(exercise['name'] ?? ''),
                          subtitle: Text(
                            (exercise['equipment'] == 1) ? 'Equipment' : 'Bodyweight',
                          ),
                          onTap: () => _showExerciseDetailsDialog(exercise),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create New Exercise'),
                onPressed: _showCreateExerciseDialog,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3), // Exercises tab (4th tab)
    );
  }
}
