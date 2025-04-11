import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';

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
              // Middle Section (60% of available height)
              Expanded(
                flex: 3, // 3 out of 5 parts (60%)
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
                                  if (index == 0) {
                                    return SizedBox(
                                      width: constraints.maxWidth / 3 - 24,
                                      height: middleConstraints.maxHeight / 2 - dynamicVerticalSpacing,
                                      child: Card(
                                        color: Colors.orange[100],
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: FutureBuilder<String>(
                                            future: DatabaseHelper().getFirstTemplateName(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return const Text('Error');
                                              } else {
                                                return Text(
                                                  snapshot.data ?? 'No Template Found',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      width: constraints.maxWidth / 3 - 24,
                                      height: middleConstraints.maxHeight / 2 - dynamicVerticalSpacing,
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
                                  }
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
              // Bottom Section (15% of available height)
              Expanded(
                flex: 1, // 1 out of 5 parts (15%)
                child: Container(
                  color: Colors.blue[300], // Placeholder color
                  child: Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.7, // 70% of the screen width
                      height: availableHeight * 0.15 * 0.4, // 40% of the bottom section height
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
    );
  }
}