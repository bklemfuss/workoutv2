import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/database_helper.dart';

// Enum to manage the toggle state for equipment exercises
enum GraphMode { weight, totalWeight }

class ExercisesGraph extends StatefulWidget {
  final int exerciseId;

  // Accept exerciseId
  const ExercisesGraph({super.key, required this.exerciseId});

  @override
  State<ExercisesGraph> createState() => _ExercisesGraphState();
}

class _ExercisesGraphState extends State<ExercisesGraph> {
  late Future<Map<String, dynamic>> _graphDataFuture;
  Map<String, dynamic>? _exerciseDetails;
  List<Map<String, dynamic>> _workoutHistory = [];
  bool _isLoading = true;
  String? _error;
  GraphMode _graphMode = GraphMode.weight; // Default mode for equipment exercises

  @override
  void initState() {
    super.initState();
    _graphDataFuture = _fetchGraphData();
  }

  // Fetch both exercise details and workout history
  Future<Map<String, dynamic>> _fetchGraphData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dbHelper = DatabaseHelper();
      final details = await dbHelper.getExerciseDetails(widget.exerciseId);
      final history = await dbHelper.getWorkoutHistoryForExercise(widget.exerciseId);

      if (details == null) {
        throw Exception('Exercise details not found.');
      }

      // Process history data: Parse dates and ensure types are correct
      final processedHistory = history.map((entry) {
        DateTime? date;
        try {
          date = DateTime.parse(entry['date'] as String);
        } catch (e) {
          print("Error parsing date: ${entry['date']}");
          // Handle error or skip entry if date is invalid
        }
        return {
          'reps': entry['reps'] as int? ?? 0,
          'weight': (entry['weight'] as num?)?.toDouble() ?? 0.0,
          'date': date, // Store as DateTime object
        };
      }).where((entry) => entry['date'] != null).toList(); // Filter out entries with invalid dates


      if (mounted) {
        setState(() {
          _exerciseDetails = details;
          _workoutHistory = processedHistory;
          _isLoading = false;
        });
      }
      return {'details': details, 'history': processedHistory};
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load graph data: $e';
          _isLoading = false;
        });
      }
      // Return an empty map or rethrow, depending on how FutureBuilder handles errors
      return Future.error(e);
    }
  }

  // Helper to build chart data points (FlSpot)
  List<FlSpot> _getChartSpots() {
    if (_workoutHistory.isEmpty) return [];

    final bool requiresEquipment = (_exerciseDetails?['equipment'] as int? ?? 0) == 1;

    List<FlSpot> spots = [];
    for (int i = 0; i < _workoutHistory.length; i++) {
      final entry = _workoutHistory[i];
      final date = entry['date'] as DateTime;
      final double xValue = date.millisecondsSinceEpoch.toDouble(); // Use timestamp for X axis
      double yValue;

      if (requiresEquipment) {
        final weight = entry['weight'] as double;
        final reps = entry['reps'] as int;
        yValue = (_graphMode == GraphMode.totalWeight) ? (weight * reps) : weight;
      } else {
        yValue = (entry['reps'] as int).toDouble();
      }
      spots.add(FlSpot(xValue, yValue));
    }
    return spots;
  }

  // Helper for bottom axis titles (dates)
  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );

    // Convert timestamp back to DateTime and format
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    // Show fewer labels to avoid clutter
    final interval = _calculateDateInterval();
    if ((value - meta.min) % interval != 0 && value != meta.min && value != meta.max) {
      return Container(); // Don't show label
    }

    return SideTitleWidget(
      child: Text(DateFormat('MM/dd').format(date), style: style), // Format as MM/dd
      meta: meta, // Pass the required meta parameter
      space: 4,
    );
  }

  // Helper for left axis titles (values)
  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );

    return SideTitleWidget(
      child: Text(value.toStringAsFixed(0), style: style), // Adjust precision if needed
      meta: meta, // Pass the required meta parameter
      space: 4,
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exerciseName = _exerciseDetails?['name'] as String? ?? 'Exercise';
    final bool requiresEquipment = (_exerciseDetails?['equipment'] as int? ?? 0) == 1;

    return Scaffold( // Wrap content in a Scaffold for structure
      appBar: AppBar(
        title: Text('Progress: $exerciseName'),
        elevation: 0, // Keep it clean
        backgroundColor: theme.colorScheme.surface, // Use surface color
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Loading and Error Handling
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))))
            else if (_workoutHistory.isEmpty)
               Expanded(child: Center(child: Text('No workout history found for $exerciseName.')))
            else ...[
              // Toggle for equipment exercises
              if (requiresEquipment)
                ToggleButtons(
                  isSelected: [_graphMode == GraphMode.weight, _graphMode == GraphMode.totalWeight],
                  onPressed: (index) {
                    setState(() {
                      _graphMode = (index == 0) ? GraphMode.weight : GraphMode.totalWeight;
                    });
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  selectedColor: theme.colorScheme.onPrimary,
                  fillColor: theme.colorScheme.primary,
                  color: theme.colorScheme.primary,
                  constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Weight')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Total Weight')),
                  ],
                ),
              if (requiresEquipment) const SizedBox(height: 16), // Spacing after toggle

              // Chart Area
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: _calculateDateInterval(), // Calculate interval dynamically
                          getTitlesWidget: _bottomTitleWidgets,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // Adjust as needed
                          getTitlesWidget: _leftTitleWidgets,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: theme.dividerColor),
                    ),
                    // minX, maxX, minY, maxY can be set explicitly or calculated
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getChartSpots(),
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true), // Show dots on data points
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    // Add touch interaction if desired
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                         getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final DateTime date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                            final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                            final String yValueLabel = touchedSpot.y.toStringAsFixed(1); // Adjust precision
                            String label = requiresEquipment
                                ? (_graphMode == GraphMode.weight ? 'Weight' : 'Total Weight')
                                : 'Reps';

                            return LineTooltipItem(
                              '$formattedDate\n$label: $yValueLabel',
                              TextStyle(color: theme.colorScheme.onPrimary),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper to calculate a reasonable interval for date labels
  double _calculateDateInterval() {
    if (_workoutHistory.length < 2) return 1; // Avoid division by zero or negative

    final firstDate = _workoutHistory.first['date'] as DateTime;
    final lastDate = _workoutHistory.last['date'] as DateTime;
    final duration = lastDate.difference(firstDate);

    // Aim for roughly 5-7 labels
    final double interval = duration.inMilliseconds / 6;

    // Ensure interval is at least one day if duration is short
    return interval > Duration.millisecondsPerDay ? interval : Duration.millisecondsPerDay.toDouble();
  }
}
