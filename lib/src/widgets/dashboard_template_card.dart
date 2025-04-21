import 'package:flutter/material.dart';
import '../theme/colors.dart'; // Import AppColors for custom colors

class DashboardTemplateCard extends StatelessWidget {
  final String templateName;
  final VoidCallback onTap;

  const DashboardTemplateCard({
    Key? key,
    required this.templateName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access the current theme

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: AppColors.primary, // Use primary color from AppColors
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            templateName,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Ensure text is visible on primary color
            ),
          ),
        ),
      ),
    );
  }
}