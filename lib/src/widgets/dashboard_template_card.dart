import 'package:flutter/material.dart';

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
    // Define a slightly different color for the header
    final headerColor = theme.colorScheme.primaryContainer; // Example: Use primaryContainer
    final cardColor = theme.cardColor; // Use theme's card color for the main body

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder( // Use LayoutBuilder for dynamic sizing/padding
          builder: (context, constraints) {
            final double cardWidth = constraints.maxWidth;
            final double cardHeight = constraints.maxHeight;
            final double horizontalPadding = cardWidth * 0.05; // 5% padding horizontally
            final double verticalPadding = cardHeight * 0.03; // 3% padding vertically

            return Column(
              children: [
                // Top Section (Template Name) - Approx 10% height
                Expanded(
                  flex: 1, // Takes up 1 part of the total flex (1+9=10)
                  child: Container(
                    width: double.infinity, // Take full width
                    color: headerColor, // Slightly different background
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding / 2),
                    child: Center(
                      child: Text(
                        templateName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // Handle long names
                        style: theme.textTheme.bodyMedium?.copyWith( // Adjust text style if needed
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer, // Text color suitable for headerColor
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom Section (Image) - Approx 90% height
                Expanded(
                  flex: 9, // Takes up 9 parts of the total flex
                  child: Container(
                    color: cardColor, // Background for the image area
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                    child: Center( // Center the content (if any) within the padded area
                      // Removed Image.asset widget
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}