import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<List<Map<String, dynamic>>> _fetchTemplates() async {
    return await DatabaseHelper().getTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppToolbar(title: 'Dashboard'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Top Section (25% of available height)
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blue[100],
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
                flex: 3,
                child: Container(
                  color: Colors.blue[200],
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchTemplates(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading templates.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No templates found.'));
                      } else {
                        final templates = snapshot.data!;
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of tiles per row
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3 / 2, // Adjust the aspect ratio of tiles
                          ),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to StartWorkoutScreen with the selected template_id
                                Navigator.pushNamed(
                                  context,
                                  '/start_workout',
                                  arguments: template['template_id'],
                                );
                              },
                              child: Card(
                                color: Colors.orange[100],
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    template['template_name'] ?? 'Unknown Template',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
              // Bottom Section (15% of available height)
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blue[300],
                  child: Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.7,
                      height: constraints.maxHeight * 0.15 * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/start_workout');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create New Workout',
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