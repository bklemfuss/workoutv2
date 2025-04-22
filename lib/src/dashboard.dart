import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'widgets/app_toolbar.dart';
import 'widgets/bottom_nav_bar.dart';
import 'theme/colors.dart'; // Import AppColors for custom colors
import 'start_workout_screen.dart';
import 'create_workout_screen.dart';
import 'widgets/dashboard_template_card.dart'; // Import the reusable card widget

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<List<Map<String, dynamic>>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _templatesFuture = _fetchTemplates();
  }

  Future<List<Map<String, dynamic>>> _fetchTemplates() async {
    return await DatabaseHelper().getTemplates();
  }

  void _showStartWorkoutScreen(BuildContext context, int templateId) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          widthFactor: 0.9,
          child: StartWorkoutScreen(templateId: templateId),
        );
      },
    );

    if (result == true) {
      // Refresh the dashboard data
      setState(() {
        _templatesFuture = _fetchTemplates();
      });
    }
  }

  void _navigateToCreateWorkoutScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateWorkoutScreen()),
    );

    if (result == true) {
      // Refresh the dashboard data
      setState(() {
        _templatesFuture = _fetchTemplates();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme

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
                  color: AppColors.background, // Use background color from AppColors
                  child: Center(
                    child: Text(
                      'Top Section (ring widgets)',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Middle Section (60% of available height)
              Expanded(
                flex: 3,
                child: Container(
                  color: AppColors.background, // Use secondary color from AppColors
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _templatesFuture,
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
                            return DashboardTemplateCard(
                              templateName: template['template_name'] ?? 'Unknown Template',
                              onTap: () {
                                _showStartWorkoutScreen(context, template['template_id']);
                              },
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
                  color: AppColors.background, // Use background color from AppColors
                  child: Center(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.7,
                      height: constraints.maxHeight * 0.15 * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateToCreateWorkoutScreen(context); // Navigate to CreateWorkoutScreen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, // Use primary color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Create New Workout',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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