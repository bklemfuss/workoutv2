import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'services/database_helper.dart'; // For fetching data

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<String>> _exerciseListFuture;

  @override
  void initState() {
    super.initState();
    _exerciseListFuture = _fetchExerciseList();
  }

  Future<List<String>> _fetchExerciseList() async {
    try {
      final workouts = await _dbHelper.getWorkoutsWithDetails();

      // Debugging: Log the fetched workouts
      debugPrint('Fetched workouts: $workouts');

      // Extract and filter exercises
      final exercises = workouts
          .map((workout) => workout['exercise_name'] as String?)
          .where((exerciseName) => exerciseName != null && exerciseName.isNotEmpty)
          .toSet()
          .toList();

      // Debugging: Log the extracted exercises
      debugPrint('Extracted exercises: $exercises');

      return exercises.cast<String>();
    } catch (e) {
      // Log the error for debugging
      debugPrint('Error in _fetchExerciseList: $e');
      rethrow; // Propagate the error to the FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const AppToolbar(title: 'Statistics'),
      body: ListView(
        padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
        children: [
          // Top Section (15% of the screen height)
          Container(
            height: screenHeight * 0.15,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: screenWidth * 0.04, // Dynamic spacing
              mainAxisSpacing: screenHeight * 0.02, // Dynamic spacing
              physics: const NeverScrollableScrollPhysics(), // Prevent GridView from scrolling
              children: [
                _buildStatCard('Total Workouts Completed', '0', theme, screenWidth, screenHeight),
                _buildStatCard('Total Exercises Performed', '0', theme, screenWidth, screenHeight),
                _buildStatCard('Total Time Exercised', '0:00', theme, screenWidth, screenHeight),
                _buildStatCard('Placeholder', '', theme, screenWidth, screenHeight),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // Dynamic spacing
          // Scrollable Charts Section
          FutureBuilder<List<String>>(
            future: _exerciseListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: screenHeight * 0.4,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No data available.',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              } else {
                final exercises = snapshot.data!;
                return SingleChildScrollView( // Make the content scrollable
                  child: Column(
                    children: [
                      _buildLineChart(exercises, theme, screenHeight, screenWidth),
                      SizedBox(height: screenHeight * 0.02), // Dynamic spacing
                      _buildBestPerformanceChart(exercises, theme, screenHeight, screenWidth),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: const FloatingStartNewWorkoutButton(),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 2,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, ThemeData theme, double screenWidth, double screenHeight) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03), // Dynamic border radius
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.01), // Dynamic spacing
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<String> exercises, ThemeData theme, double screenHeight, double screenWidth) {
    return Container(
      height: screenHeight * 0.4,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.03), // Dynamic border radius
      ),
      child: Column(
        children: [
          DropdownButton<String>(
            hint: const Text('Select Exercise'),
            items: exercises.map((exercise) {
              return DropdownMenuItem(
                value: exercise,
                child: Text(exercise),
              );
            }).toList(),
            onChanged: (value) {
              // Handle exercise selection
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 1),
                        FlSpot(1, 3),
                        FlSpot(2, 2),
                        FlSpot(3, 1.5),
                        FlSpot(4, 2.5),
                      ],
                      isCurved: true,
                      color: theme.primaryColor,
                      barWidth: screenWidth * 0.01, // Dynamic bar width
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestPerformanceChart(List<String> exercises, ThemeData theme, double screenHeight, double screenWidth) {
    return Container(
      height: screenHeight * 0.4,
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.03), // Dynamic border radius
      ),
      child: Column(
        children: [
          DropdownButton<String>(
            hint: const Text('Select Exercise'),
            items: exercises.map((exercise) {
              return DropdownMenuItem(
                value: exercise,
                child: Text(exercise),
              );
            }).toList(),
            onChanged: (value) {
              // Handle exercise selection
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                'Best Performance Chart Placeholder',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}