import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

class WeeklyWorkoutsGraph extends StatefulWidget {
  final int weeklyGoal; // Define the weekly workout goal

  const WeeklyWorkoutsGraph({super.key, this.weeklyGoal = 3}); // Default goal is 3

  @override
  State<WeeklyWorkoutsGraph> createState() => _WeeklyWorkoutsGraphState();
}

class _WeeklyWorkoutsGraphState extends State<WeeklyWorkoutsGraph> {
  late Future<List<Map<String, dynamic>>> _weeklyDataFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _weeklyDataFuture = _dbHelper.getWeeklyWorkoutCounts(numberOfWeeks: 8); // Fetch last 8 weeks
  }

  Color _getBarColor(int count, int goal) {
    if (count == 0) {
      return Colors.grey.shade300; // Light grey for zero workouts
    } else if (count >= goal) {
      return Colors.green; // Green for meeting or exceeding goal
    } else if (count >= goal / 2) {
      return Colors.yellow.shade700; // Yellow for more than half way
    } else {
      return Colors.red; // Red for less than half way
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Workouts'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _weeklyDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No weekly workout data available.'));
          }

          final weeklyData = snapshot.data!;
          // Calculate maxY ensuring the goal line and highest bar are visible
          final maxCount = weeklyData.map((d) => d['count'] as int).fold<int>(0, (max, current) => current > max ? current : max);
          final maxYValue = (maxCount > widget.weeklyGoal ? maxCount : widget.weeklyGoal) + 2.0; // Add padding above the max value or goal

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxYValue, // Use calculated max Y
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    // Note: 'tooltipBgColor' is the standard parameter name in fl_chart.
                    // If you still see an 'undefined_named_parameter' error,
                    // please check your fl_chart package version and its documentation.
                    //tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final weekData = weeklyData[groupIndex];
                      final weekStart = weekData['weekStartDate'] as DateTime;
                      final weekLabel = DateFormat('MMM d').format(weekStart);
                      return BarTooltipItem(
                        '$weekLabel\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${rod.toY.toInt()} workouts',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      // Note: The signature (double value, TitleMeta meta) is standard for getTitlesWidget.
                      // If you see a 'meta is required' error, check your fl_chart version or IDE analysis.
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < weeklyData.length) {
                          final weekStart = weeklyData[index]['weekStartDate'] as DateTime;
                          // Show month/day for clarity
                          return SideTitleWidget(
                            meta: meta,
                            space: 4.0,
                            child: Text(DateFormat('M/d').format(weekStart), style: theme.textTheme.bodySmall),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1, // Show every integer value
                       // Note: The signature (double value, TitleMeta meta) is standard for getTitlesWidget.
                       getTitlesWidget: (double value, TitleMeta meta) {
                        // Avoid drawing 0 label and potentially overlapping max label if needed
                        if (value == 0) return Container();
                        // Optionally hide max label if it overlaps with goal label or looks cluttered
                        // if (value == maxYValue) return Container();
                        return Text(value.toInt().toString(), style: theme.textTheme.bodySmall, textAlign: TextAlign.left);
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false, // Hide vertical grid lines
                  horizontalInterval: 1, // Grid line for every integer
                   getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor.withOpacity(0.1), // Use theme divider color
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false, // Hide the outer border
                ),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final count = data['count'] as int;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: _getBarColor(count, widget.weeklyGoal),
                        width: 16, // Adjust bar width as needed
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                // Add horizontal line for the goal
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: widget.weeklyGoal.toDouble(),
                      color: theme.colorScheme.primary.withOpacity(0.8), // Use primary theme color
                      strokeWidth: 2,
                      dashArray: [5, 5], // Make it dotted/dashed
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 2),
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 10),
                        labelResolver: (line) => '${widget.weeklyGoal} Goal',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
