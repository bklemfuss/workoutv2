import 'dart:math';
import 'package:flutter/material.dart';

class GoalProgressRing extends StatefulWidget {
  final int currentValue;
  final int goalValue;
  final String label;
  final double size;
  final double strokeWidth;

  const GoalProgressRing({
    Key? key,
    required this.currentValue,
    required this.goalValue,
    required this.label,
    this.size = 100.0,
    this.strokeWidth = 10.0,
  }) : super(key: key);

  @override
  State<GoalProgressRing> createState() => _GoalProgressRingState();
}

class _GoalProgressRingState extends State<GoalProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // Animation duration
      vsync: this,
    );

    // Ensure goalValue is not zero to avoid division by zero
    final double endValue = widget.goalValue > 0
        ? (widget.currentValue / widget.goalValue).clamp(0.0, 1.0)
        : 0.0;

    _animation = Tween<double>(begin: 0.0, end: endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {}); // Redraw on animation tick
      });

    _controller.forward(); // Start the animation
  }

  @override
  void didUpdateWidget(GoalProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the values change, update the animation
    if (widget.currentValue != oldWidget.currentValue ||
        widget.goalValue != oldWidget.goalValue) {
      final double endValue = widget.goalValue > 0
          ? (widget.currentValue / widget.goalValue).clamp(0.0, 1.0)
          : 0.0;
      _animation = Tween<double>(
              begin: _animation.value, // Start from current animation value
              end: endValue)
          .animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.forward(from: 0.0); // Restart animation smoothly
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return Colors.blue.shade400; // Goal reached color
    } else if (progress >= 0.75) {
      return Colors.green.shade400; // Green
    } else if (progress >= 0.4) {
      return Colors.yellow.shade600; // Yellow
    } else {
      return Colors.red.shade400; // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _animation.value;
    final color = _getProgressColor(progress);
    final displayValue = (progress * widget.goalValue).round();
    final goalReached = progress >= 1.0;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: 1.0, // Full circle
              strokeWidth: widget.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onSurface.withOpacity(0.1), // Background color
              ),
            ),
          ),
          // Progress ring
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Transform.rotate(
              angle: -pi / 2, // Start from the top
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: widget.strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                // Add completion effect (e.g., slight glow)
                backgroundColor: goalReached ? color.withOpacity(0.3) : null,
              ),
            ),
          ),
          // Text inside the ring
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${displayValue}/${widget.goalValue}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color, // Match text color to progress
                ),
              ),
              Text(
                widget.label,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
