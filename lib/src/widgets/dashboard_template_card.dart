import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/database_helper.dart';

class DashboardTemplateCard extends StatefulWidget {
  final String templateName;
  final int templateId;
  final VoidCallback onTap;

  const DashboardTemplateCard({
    Key? key,
    required this.templateName,
    required this.templateId,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DashboardTemplateCard> createState() => _DashboardTemplateCardState();
}

class _DashboardTemplateCardState extends State<DashboardTemplateCard> {
  late Future<Map<String, int>> _muscleGroupCountsFuture;

  @override
  void initState() {
    super.initState();
    _muscleGroupCountsFuture = DatabaseHelper().getMuscleGroupCountsForTemplate(widget.templateId);
  }

  Color? _getOverlayColor(int count) {
    if (count >= 5) return Colors.red.withOpacity(0.7);
    if (count >= 3) return Colors.orange.withOpacity(0.7);
    if (count >= 1) return Colors.yellow.withOpacity(0.7);
    return null;
  }

  String? _getMuscleGroupAsset(String group) {
    switch (group.toLowerCase()) {
      case 'arms': return 'assets/wireGuySVG_Arms.svg';
      case 'legs': return 'assets/wireGuySVG_Legs.svg';
      case 'chest': return 'assets/wireGuySVG_Chest.svg';
      case 'core':
      case 'abs': return 'assets/wireGuySVG_Abs.svg';
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerColor = theme.colorScheme.primaryContainer;
    final cardColor = theme.cardColor;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = constraints.maxWidth;
            final double cardHeight = constraints.maxHeight;
            final double horizontalPadding = cardWidth * 0.05;
            final double verticalPadding = cardHeight * 0.03;

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: headerColor,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding / 2),
                    child: Center(
                      child: Text(
                        widget.templateName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    color: cardColor,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                    child: Center(
                      child: FutureBuilder<Map<String, int>>(
                        future: _muscleGroupCountsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              width: 60, height: 60,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          final List<Widget> stackChildren = [
                            SvgPicture.asset(
                              'assets/wireGuySVG.svg',
                              width: cardWidth * 0.7,
                              height: cardHeight * 0.7,
                              fit: BoxFit.contain,
                            ),
                          ];
                          if (snapshot.hasData) {
                            final counts = snapshot.data!;
                            for (final group in ['Arms', 'Legs', 'Chest', 'Abs', 'Core']) {
                              final count = counts[group] ?? counts[group.toLowerCase()] ?? 0;
                              final asset = _getMuscleGroupAsset(group);
                              final color = _getOverlayColor(count);
                              if (asset != null && color != null) {
                                stackChildren.add(
                                  SvgPicture.asset(
                                    asset,
                                    width: cardWidth * 0.7,
                                    height: cardHeight * 0.7,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                                  ),
                                );
                              }
                            }
                          }
                          return Stack(
                            alignment: Alignment.center,
                            children: stackChildren,
                          );
                        },
                      ),
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