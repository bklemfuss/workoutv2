import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/exercise_details_dialog.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({Key? key}) : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  String _searchQuery = '';
  String _selectedBodyWeight = 'All';
  bool _showBodyweightOnly = false; // New state for radio button

  final List<String> _bodyWeightOptions = ['All', 'Bodyweight', 'Equipment'];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    final db = DatabaseHelper();
    final allExercises = await db.getAllExercises();
    setState(() {
      _exercises = allExercises;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredExercises = _exercises.where((exercise) {
        final matchesSearch = exercise['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchesBodyWeight = _selectedBodyWeight == 'All'
            ? true
            : (_selectedBodyWeight == 'Bodyweight'
                ? exercise['equipment'] == 0
                : exercise['equipment'] == 1);
        final matchesEquipment = _showBodyweightOnly ? exercise['equipment'] == 0 : true;
        return matchesSearch && matchesBodyWeight && matchesEquipment;
      }).toList();
    });
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _applyFilters();
  }

  void _onBodyWeightChanged(String? value) {
    if (value != null) {
      _selectedBodyWeight = value;
      _applyFilters();
    }
  }

  void _showExerciseDetailsDialog(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) {
        return ExerciseDetailsDialog(exercise: exercise);
      },
    );
  }

  void _navigateToCreateExercise() {
    Navigator.pushNamed(context, '/create_workout'); // Reuse create_workout_screen for now
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
                    value: _showBodyweightOnly,
                    onChanged: (val) {
                      setState(() {
                        _showBodyweightOnly = val;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const Text('Filter by:'),
                DropdownButton<String>(
                  value: _selectedBodyWeight,
                  items: _bodyWeightOptions
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: _onBodyWeightChanged,
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
                onPressed: _navigateToCreateExercise,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3), // Exercises tab (4th tab)
    );
  }
}
