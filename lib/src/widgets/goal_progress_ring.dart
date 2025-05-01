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
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  bool _goalReachedPreviously = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sparkleAnimation = CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    );

    _updateProgressAnimation();
    _checkAndTriggerSparkle();

    _progressController.forward();
  }

  void _updateProgressAnimation() {
    final double endValue = widget.goalValue > 0
        ? (widget.currentValue / widget.goalValue).clamp(0.0, 1.0)
        : 0.0;

    final double beginValue =
        _progressController.isAnimating ? _progressAnimation.value : 0.0;

    _progressAnimation = Tween<double>(begin: beginValue, end: endValue).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
        _checkAndTriggerSparkle();
      });
  }

  void _checkAndTriggerSparkle() {
    final goalReached = _progressAnimation.value >= 1.0;
    if (goalReached && !_goalReachedPreviously) {
      _sparkleController.forward(from: 0.0);
      _goalReachedPreviously = true;
    } else if (!goalReached) {
      _goalReachedPreviously = false;
    }
  }

  @override
  void didUpdateWidget(GoalProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != oldWidget.currentValue ||
        widget.goalValue != oldWidget.goalValue) {
      _updateProgressAnimation();
      _progressController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return Colors.blue.shade400;
    } else if (progress >= 0.75) {
      return Colors.green.shade400;
    } else if (progress >= 0.4) {
      return Colors.yellow.shade600;
    } else {
      return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _progressAnimation.value;
    final color = _getProgressColor(progress);
    final displayValue = (progress * widget.goalValue).round();
    final goalReached = progress >= 1.0;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: widget.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
          ),
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Transform.rotate(
              angle: -pi / 2,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: widget.strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: goalReached ? color.withOpacity(0.3) : null,
              ),
            ),
          ),
          if (_goalReachedPreviously || _sparkleController.isAnimating)
            AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return _sparkleAnimation.value > 0
                    ? CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: SparklePainter(
                          animationValue: _sparkleAnimation.value,
                          color: color,
                          strokeWidth: widget.strokeWidth,
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${displayValue}/${widget.goalValue}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
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

class SparklePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;
  final int sparkleCount;
  final List<Offset> _sparklePositions = [];
  final Random _random = Random();

  SparklePainter({
    required this.animationValue,
    required this.color,
    required this.strokeWidth,
    this.sparkleCount = 15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sparkleRadius = radius + strokeWidth * 0.5;

    if (_sparklePositions.isEmpty) {
      for (int i = 0; i < sparkleCount; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final r = sparkleRadius +
            (_random.nextDouble() * strokeWidth * 1.5) -
            (strokeWidth * 0.75);
        _sparklePositions.add(
          Offset(center.dx + r * cos(angle), center.dy + r * sin(angle)),
        );
      }
    }

    final double opacity = (animationValue < 0.5)
        ? animationValue * 2
        : (1.0 - animationValue) * 2;

    final paint = Paint()
      ..color = color.withOpacity(opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    for (final pos in _sparklePositions) {
      final sparkleSize = (strokeWidth / 4) * (1 + (animationValue * 0.5));
      canvas.drawCircle(pos, sparkleSize.clamp(1.0, strokeWidth / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
