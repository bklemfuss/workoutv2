import 'package:flutter/material.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/floating_start_new_workout_button.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'Dashboard'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the available height excluding the AppBar and BottomNavBar
          final availableHeight = constraints.maxHeight;

          return Column(
            children: [
              // Top Section (25% of available height)
              Expanded(
                flex: 1, // 1 out of 4 parts (25%)
                child: Container(
                  color: Colors.blue[100], // Placeholder color
                  child: const Center(
                    child: Text(
                      'Top Section (ring widgets)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              // Middle Section (50% of available height)
              Expanded(
                flex: 2, // 2 out of 4 parts (50%)
                child: Container(
                  color: Colors.blue[200], // Placeholder color
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(
                          width: constraints.maxWidth, // Ensure tiles fit within the screen width
                          child: LayoutBuilder(
                            builder: (context, middleConstraints) {
                              // Calculate dynamic vertical spacing based on the middle section height
                              final dynamicVerticalSpacing =
                                  (middleConstraints.maxHeight * 0.05).clamp(8.0, 24.0);

                              return Wrap(
                                spacing: 16, // Static horizontal spacing
                                runSpacing: dynamicVerticalSpacing, // Dynamic vertical spacing
                                alignment: WrapAlignment.start,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: constraints.maxWidth / 3 - 24, // 3 tiles per row
                                    height: middleConstraints.maxHeight / 2 - dynamicVerticalSpacing, // 2 rows
                                    child: Card(
                                      color: Colors.orange[100],
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Workout ${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom Section (25% of available height)
              Expanded(
                flex: 1, // 1 out of 4 parts (25%)
                child: Container(
                  color: Colors.blue[300], // Placeholder color
                  child: Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.7, // 70% of the screen width
                      height: availableHeight * 0.25 * 0.4, // 40% of the bottom section height
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/pre_workout');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Customize button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                        ),
                        child: const Text(
                          'Start New Workout',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0,
      ),
      floatingActionButton: const FloatingStartNewWorkoutButton(),
    );
  }
}