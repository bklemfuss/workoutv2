import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'services/database_helper.dart';
import 'providers/unit_provider.dart'; // Import UnitProvider

class PostWorkoutScreen extends StatelessWidget {
  const PostWorkoutScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchWorkoutDetails(
      BuildContext context) async {
    final workoutId = ModalRoute.of(context)!.settings.arguments as int;
    final dbHelper = DatabaseHelper();
    final workoutDetails = await dbHelper.getWorkoutDetails(workoutId);
    final workoutExercises = await dbHelper.getWorkoutExercises(workoutId);
    final totalWorkouts = (await dbHelper.getWorkouts()).length;
    // Fetch previous PRs
    final previousPRs = await dbHelper.getPreviousExercisePRs(workoutId);

    return {
      'workoutDetails': workoutDetails,
      'workoutExercises': workoutExercises,
      'totalWorkouts': totalWorkouts,
      'previousPRs': previousPRs, // Add PRs to the result map
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme
    final loc = AppLocalizations.of(context)!; // Access localized strings
    final unitProvider =
        Provider.of<UnitProvider>(context); // Access UnitProvider
    final isMetric = unitProvider.unitSystem == 'Metric'; // Check unit system

    return Scaffold(
      appBar: AppBar(title: Text(loc.postWorkoutSummary)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchWorkoutDetails(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(loc.errorLoadingWorkoutSummary(
                          snapshot.error.toString())));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text(loc.noWorkoutSummaryFound));
                }

                final workoutDetails = snapshot.data!['workoutDetails'];
                final workoutExercises = snapshot.data!['workoutExercises']
                    as List<Map<String, dynamic>>; // Cast for type safety
                final totalWorkouts = snapshot.data!['totalWorkouts'];
                final workoutTimerSeconds =
                    workoutDetails['workout_timer'] as int? ??
                        0; // Get timer value
                // Extract previous PRs
                final previousPRs = snapshot.data!['previousPRs']
                    as Map<String, Map<String, double>>;

                // Format timer value
                final hours = workoutTimerSeconds ~/ 3600;
                final minutes = (workoutTimerSeconds % 3600) ~/ 60;
                final seconds = workoutTimerSeconds % 60;
                final formattedTime = hours > 0
                    ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                    : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

                // Group exercises by name
                final Map<String, List<Map<String, dynamic>>> groupedExercises =
                    {};
                for (var exercise in workoutExercises) {
                  final name = exercise['exercise_name'] as String? ??
                      'Unknown Exercise';
                  (groupedExercises[name] ??= []).add(exercise);
                }
                final exerciseNames = groupedExercises.keys.toList();
                final weightUnit =
                    isMetric ? 'kg' : 'lbs'; // Determine unit label

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You finished your $totalWorkouts workout!', // Consider making this ordinal (1st, 2nd, 3rd...)
                        style: theme.textTheme
                            .headlineSmall, // Use a more prominent style
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Workout: ${workoutDetails['template_name'] ?? 'Unnamed Workout'}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4), // Add small space
                      Text(
                        // Display formatted workout time
                        'Duration: $formattedTime',
                        style: theme
                            .textTheme.bodyMedium, // Use a less prominent style
                      ),
                      const SizedBox(height: 16),
                      // Title for the exercise list
                      Text(
                        'Exercises Completed:',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Updated ListView to show grouped exercises
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              exerciseNames.length, // Count of unique exercises
                          itemBuilder: (context, index) {
                            final exerciseName = exerciseNames[index];
                            final exerciseEntries =
                                groupedExercises[exerciseName]!;
                            // Get historical PRs for this specific exercise, default to 0 if not found
                            final historicalMaxWeight =
                                previousPRs[exerciseName]?['maxWeight'] ?? 0.0;
                            final historicalMaxVolume =
                                previousPRs[exerciseName]?['maxVolume'] ?? 0.0;

                            // Card for each unique exercise
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              color: theme.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Exercise Name Header
                                    Text(
                                      exerciseName,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // List each weight/rep entry with potential PR icons
                                    ...exerciseEntries.map((entry) {
                                      final weight = (entry['weight'] as num?)
                                              ?.toDouble() ??
                                          0.0;
                                      final reps = entry['reps'] as int? ?? 0;
                                      final currentVolume = weight * reps;

                                      // Check for PRs
                                      final isWeightPR =
                                          weight > historicalMaxWeight &&
                                              weight > 0;
                                      final isVolumePR =
                                          currentVolume > historicalMaxVolume &&
                                              currentVolume > 0;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        // Use a Row to potentially add icons
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween, // Align icons to the right
                                          children: [
                                            Text(
                                              '${weight} $weightUnit x $reps reps',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                            // Row for PR icons
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isWeightPR)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    // Wrap with Tooltip
                                                    child: Tooltip(
                                                      message: 'Weight Record',
                                                      child: Icon(
                                                          Icons.fitness_center,
                                                          size: 18,
                                                          color: theme
                                                              .colorScheme
                                                              .primary),
                                                    ),
                                                  ),
                                                if (isVolumePR)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .only(
                                                        left:
                                                            4.0), // Add spacing if both icons appear
                                                    // Wrap with Tooltip
                                                    child: Tooltip(
                                                      message: 'Volume Record',
                                                      child: Icon(Icons.star,
                                                          size: 18,
                                                          color: Colors.amber),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Add Done button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard',
                    (route) => false,
                  );
                },
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
