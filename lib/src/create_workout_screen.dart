import 'package:flutter/material.dart';
import 'services/database_helper.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final TextEditingController searchController = TextEditingController();
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
          // Exercise List (Remaining 85%)
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}