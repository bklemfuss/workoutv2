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
    final workouts = await _dbHelper.getWorkoutsWithDetails();
    _workoutDates = {
      for (var workout in workouts)
        DateFormat('yyyy-MM-dd').format(DateTime.parse(workout['date'])): workout['workout_id'],
    };
    return workouts;
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
            return Center(
              child: Text(
                'Error loading workouts.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          } else {
            return Column(
              children: [
                // Calendar Section
                TableCalendar(
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
                // Remaining Section
                Expanded(
                  child: Center(
                    child: Text(
                      'Select a date to view workout details.',
                      style: theme.textTheme.bodyLarge,
                    ),
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