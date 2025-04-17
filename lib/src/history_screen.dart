import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';
import 'theme/colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _workoutsFuture;
  Map<String, int> _workoutDates = {}; // Map of date strings to workout IDs
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = _fetchWorkouts();
  }

  Future<List<Map<String, dynamic>>> _fetchWorkouts() async {
    try {
      final workouts = await _dbHelper.getWorkoutsWithDetails();

      // Filter out invalid data
      final validWorkouts = workouts.where((workout) {
        final date = workout['date'];
        final workoutId = workout['workout_id'];
        if (date == null || workoutId == null) {
          debugPrint('Invalid workout data: $workout');
          return false;
        }
        return true;
      }).toList();

      // Sort by date
      validWorkouts.sort((a, b) {
        try {
          return DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']));
        } catch (e) {
          debugPrint('Error parsing date: ${b['date']} or ${a['date']}');
          return 0;
        }
      });

      // Map workout dates to workout IDs
      _workoutDates = {
        for (var workout in validWorkouts)
          DateFormat('yyyy-MM-dd').format(DateTime.parse(workout['date'])): workout['workout_id'],
      };

      return validWorkouts;
    } catch (e) {
      debugPrint('Error in _fetchWorkouts: $e');
      rethrow;
    }
  }

  void _onDateSelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _focusedDate = focusedDate;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    if (_workoutDates.containsKey(formattedDate)) {
      // Navigate to WorkoutSummaryScreen if a workout exists for the selected date
      final workoutId = _workoutDates[formattedDate];
      Navigator.pushNamed(
        context,
        '/workout_summary',
        arguments: workoutId,
      );
    } else {
      // Do nothing if no workout exists for the selected date
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No workout found for this date.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppToolbar(title: 'History'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display the error message
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyLarge,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No workouts found.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          } else {
            final workouts = snapshot.data!;
            return Column(
              children: [
                // Calendar Section (40% of the screen height)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: TableCalendar(
                    firstDay: DateTime(2000),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDate,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: _onDateSelected,
                    calendarStyle: CalendarStyle(
                      defaultDecoration: BoxDecoration(
                        color: AppColors.primary, // Dates without workouts
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.textPrimary, // Highlight today's date
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.secondary, // Selected date
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AppColors.secondary, // Dates with workouts
                        shape: BoxShape.circle,
                      ),
                    ),
                    eventLoader: (day) {
                      final formattedDate = DateFormat('yyyy-MM-dd').format(day);
                      return _workoutDates.containsKey(formattedDate) ? [true] : [];
                    },
                  ),
                ),
                // Scrollable List of Workouts (60% of the screen height)
                Expanded(
                  child: ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: AppColors.secondary, // Use secondary color for cards
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            workout['template_name'] ?? 'Unknown Template',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ), // Use theme's text style
                          ),
                          subtitle: Text(
                            'Date: ${workout['date']}',
                            style: theme.textTheme.bodyMedium, // Use theme's text style
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/workout_summary',
                              arguments: workout['workout_id'],
                            );
                          },
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
      floatingActionButton: const FloatingStartNewWorkoutButton(),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}