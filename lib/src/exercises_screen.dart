import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      _filteredExercises = _exercises.where((exercise) {
        final matchesSearch = exercise['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchesMuscleGroup = _selectedMuscleGroup == 'All'
            ? true
            : (exercise['muscle_group'] == _selectedMuscleGroup);
        final matchesBodyweight = !_bodyweightOnly
            ? true
            : (exercise['equipment'] == 0 || exercise['equipment'] == false || exercise['equipment'] == '0');
        return matchesSearch && matchesMuscleGroup && matchesBodyweight;
      }).toList();
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.exercisesTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: loc.searchExercisesHint,
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
                Text(loc.filterByMuscleGroup),
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
                    Text(loc.bodyweightOnly),
                    Switch(
                      value: _bodyweightOnly,
                      onChanged: _onBodyweightSwitchChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(child: Text(loc.noExercisesFound))
                : ListView.builder(
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(exercise['name'] ?? ''),
                          subtitle: Text(
                            (exercise['equipment'] == 1) ? loc.requiresEquipment : loc.bodyweightOnly,
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
                label: Text(loc.createNewExercise),
                onPressed: _showCreateExerciseDialog,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
