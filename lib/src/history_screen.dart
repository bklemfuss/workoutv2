import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'workout_summary.dart';

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
  DateTime? _selectedDate = DateTime.now(); // Initialize with today's date

  @override
  void initState() {
    super.initState();
    _workoutsFuture = _fetchWorkouts();
    // _selectedDate is already initialized above
  }

  Future<List<Map<String, dynamic>>> _fetchWorkouts() async {
    try {
      final workouts = await _dbHelper.getWorkoutsWithDetails();

      // Filter out invalid data
      final validWorkouts = workouts.where((workout) {
        final date = workout['date'];
        final workoutId = workout['workout_id'];
        // Basic check for null date or id
        if (date == null || workoutId == null) {
          debugPrint('Invalid workout data (null date or id): $workout');
          return false;
        }
        // Attempt to parse the date to ensure it's valid
        try {
          DateTime.parse(date);
          return true;
        } catch (e) {
          debugPrint('Invalid date format in workout data: $workout');
          return false;
        }
      }).toList();

      // Sort by date (most recent first)
      validWorkouts.sort((a, b) {
        try {
          // Ensure dates are parsed before comparison
          return DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']));
        } catch (e) {
          // Handle potential parsing errors during sort, though filtering should prevent this
          debugPrint('Error parsing date during sort: ${b['date']} or ${a['date']}');
          return 0; // Maintain original order if parsing fails
        }
      });

      // Map dates with workouts for calendar markers
      _workoutDates = {
        for (var workout in validWorkouts)
          // Ensure date is valid before formatting
          DateFormat('yyyy-MM-dd').format(DateTime.parse(workout['date'])): workout['workout_id'], // Value doesn't matter much here, just the key presence
      };

      return validWorkouts;
    } catch (e) {
      debugPrint('Error in _fetchWorkouts: $e');
      // Consider showing an error message to the user or logging more details
      return Future.error('Failed to load workouts: $e'); // Propagate error
    }
  }

  // Updated _onDateSelected: Only updates state to trigger rebuild and list filtering
  void _onDateSelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      // Toggle selection: if the same day is tapped again, revert to today.
      if (isSameDay(_selectedDate, selectedDate)) {
        _selectedDate = DateTime.now(); // Revert to today
        _focusedDate = DateTime.now(); // Also focus today
      } else {
        _selectedDate = selectedDate;
        _focusedDate = focusedDate; // Update focused day to selected day
      }
    });
    // The list below will now filter based on _selectedDate.
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading workouts: ${snapshot.error}', // Show specific error
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
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
            final allWorkouts = snapshot.data!;

            // Filter workouts based on the selected date (which defaults to today)
            final displayedWorkouts = allWorkouts.where((workout) {
              try {
                // Safely parse date and compare
                // Ensure _selectedDate is not null before comparing
                return _selectedDate != null && isSameDay(DateTime.parse(workout['date']), _selectedDate);
              } catch (e) {
                debugPrint('Error parsing date for filtering: ${workout['date']}');
                return false; // Exclude if date is invalid
              }
            }).toList();

            // Determine if the currently selected/default date is today
            final bool isTodaySelected = _selectedDate != null && isSameDay(_selectedDate, DateTime.now());

            return Column(
              children: [
                // Calendar Section
                SizedBox(
                  // Keep calendar height fixed or dynamic as preferred
                  height: MediaQuery.of(context).size.height * 0.5, // Slightly increased height
                  child: TableCalendar(
                    firstDay: DateTime(2000),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDate,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: _onDateSelected,
                    calendarStyle: CalendarStyle(
                      // Remove the shape and potentially set color to transparent
                      // to avoid the default circle on all past dates.
                      defaultDecoration: BoxDecoration(
                        color: Colors.transparent, // Or theme.canvasColor if preferred
                        // shape: BoxShape.circle, // REMOVED
                      ),
                      // Keep today's decoration as a circle
                      todayDecoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.5), // Slightly transparent today
                        shape: BoxShape.circle,
                      ),
                      // Keep selected decoration as a circle
                      selectedDecoration: BoxDecoration(
                        color: theme.colorScheme.secondary, // Selected date
                        shape: BoxShape.circle,
                      ),
                      // Marker for days with workouts (small dot)
                      markerDecoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      // Ensure text styles contrast with background
                      defaultTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      weekendTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7)), // Slightly dimmer weekends
                      todayTextStyle: TextStyle(color: theme.colorScheme.onPrimary), // Text color on today's highlight
                      selectedTextStyle: TextStyle(color: theme.colorScheme.onSecondary), // Text color on selected highlight
                      // Add outside days style if needed
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false, // Hide format button if not needed
                      titleCentered: true,
                      titleTextStyle: theme.textTheme.titleLarge ?? const TextStyle(),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          // Customize marker appearance if needed
                          return Positioned(
                            right: 1,
                            bottom: 1,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.secondary, // Match markerDecoration
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    eventLoader: (day) {
                      final formattedDate = DateFormat('yyyy-MM-dd').format(day);
                      // Check if any workout exists for this date using the pre-calculated map
                      return _workoutDates.containsKey(formattedDate) ? [true] : [];
                    },
                  ),
                ),

                // Divider between Calendar and List
                const Divider(height: 1, thickness: 1),

                // Conditional Message or List Title
                if (_selectedDate != null && displayedWorkouts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      isTodaySelected
                          ? 'No workouts recorded today.'
                          : 'No workouts recorded on ${DateFormat.yMMMd().format(_selectedDate!)}.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (_selectedDate != null)
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 8.0),
                     child: Text(
                       isTodaySelected
                           ? 'Workouts Today'
                           : 'Workouts on ${DateFormat.yMMMd().format(_selectedDate!)}',
                       style: theme.textTheme.titleMedium,
                       textAlign: TextAlign.center, // Center the title
                     ),
                   ),

                // Scrollable List of Workouts (Filtered)
                Expanded(
                  // The list should only be empty if displayedWorkouts is empty.
                  // The initial "No workouts found." message is handled by the outer snapshot check.
                  child: displayedWorkouts.isEmpty
                      ? Container() // Show nothing further if list is empty (message handled above)
                      : ListView.separated( // Use ListView.separated
                          itemCount: displayedWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout = displayedWorkouts[index];
                            String formattedDate = 'Invalid Date';
                            try {
                              // Format as DD, MON, YYYY (e.g., 05, JUN, 2024)
                              final date = DateTime.parse(workout['date']);
                              formattedDate = DateFormat('dd, MMM, yyyy').format(date).toUpperCase();
                            } catch (e) {
                              debugPrint('Error formatting date for display: ${workout['date']}');
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: theme.cardColor, // Use theme card color
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  workout['template_name'] ?? 'Workout', // Provide default
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Completed: $formattedDate', // Show formatted date/time
                                  style: theme.textTheme.bodyMedium,
                                ),
                                trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color), // Use chevron
                                onTap: () async {
                                  // Show WorkoutSummaryScreen in a BottomModalSheet
                                  final result = await showModalBottomSheet<bool>(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    builder: (context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.9, // Adjust the height of the modal sheet
                                        child: WorkoutSummaryScreen(workoutId: workout['workout_id']),
                                      );
                                    },
                                  );

                                  // Refresh the history screen if a workout was deleted
                                  if (result == true) {
                                    setState(() {
                                      _workoutsFuture = _fetchWorkouts();
                                    });
                                  }
                                },
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            height: 1, // Minimal height for the divider line
                            thickness: 1,
                            indent: 16, // Indent divider from the left edge
                            endIndent: 16, // Indent divider from the right edge
                          ),
                        ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 1, // History tab
      ),
    );
  }
}