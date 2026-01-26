import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProcessingAnimationWidget extends StatefulWidget {
  final double size;
  final Color? color;

  const ProcessingAnimationWidget({super.key, this.size = 100, this.color});

  @override
  State<ProcessingAnimationWidget> createState() =>
      _ProcessingAnimationWidgetState();
}

class _ProcessingAnimationWidgetState extends State<ProcessingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gearColor = widget.color ?? theme.colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Large main gear (Rotate clockwise)
          Positioned(
            left: 0,
            top: 0,
            child: _buildRotatingGear(
              icon: FontAwesomeIcons.gear,
              size: widget.size * 0.6,
              color: gearColor,
              controller: _controller,
              clockwise: true,
            ),
          ),

          // Medium gear (Rotate counter-clockwise)
          Positioned(
            right: 0,
            bottom: widget.size * 0.1,
            child: _buildRotatingGear(
              icon: FontAwesomeIcons.gear,
              size: widget.size * 0.45,
              color: gearColor.withValues(alpha: 0.8),
              controller: _controller,
              clockwise: false,
              speedMultiplier: 1.5,
            ),
          ),

          // Small gear (Rotate clockwise)
          Positioned(
            left: widget.size * 0.2,
            bottom: 0,
            child: _buildRotatingGear(
              icon: FontAwesomeIcons.gear,
              size: widget.size * 0.35,
              color: gearColor.withValues(alpha: 0.6),
              controller: _controller,
              clockwise: true,
              speedMultiplier: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingGear({
    required IconData icon,
    required double size,
    required Color color,
    required AnimationController controller,
    bool clockwise = true,
    double speedMultiplier = 1.0,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double angle = controller.value * 2 * math.pi * speedMultiplier;
        return Transform.rotate(
          angle: clockwise ? angle : -angle,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: FittedBox(child: FaIcon(icon, color: color)),
          ),
        );
      },
    );
  }
}
