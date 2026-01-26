import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/screens/welcome_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const SplashScreen({super.key, required this.themeNotifier});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _mainController;
  late AnimationController _scanSequenceController;
  late AnimationController _flowController;
  late AnimationController _pulseController;
  late AnimationController _vibrationController;
  late AnimationController _rippleController; // New: For alert ripples

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _leafOpacities;

  // Configuration
  final int _sickLeafIndex = 2;
  final List<int> _scanPathIndices = [0, 4, 2];
  final List<Particle> _particles = []; // Ambient particles

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _initParticles();
    _startSequence();
  }

  void _initControllers() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scanSequenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _flowController = AnimationController(
      vsync: this,
      duration: AppConstants.splashFlowDuration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _vibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _initAnimations() {
    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
    );

    _leafOpacities = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.2 + 0.1,
          theta: random.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  Offset _getLeafOffset(int index, double radius) {
    final angle = (index * 2 * math.pi) / 6;
    return Offset(radius * math.cos(angle), radius * math.sin(angle));
  }

  void _startSequence() {
    _mainController.forward().then((_) {
      if (!mounted) return;

      _flowController.repeat();
      _pulseController.repeat(reverse: true);

      _scanSequenceController.forward().then((_) {
        if (!mounted) return;

        // Disease Detected!
        _vibrationController.repeat(reverse: true);
        _rippleController.repeat(); // Start Ripples

        Future.delayed(const Duration(milliseconds: 2000), () {
          // Slightly longer wait to see ripples
          _navigateAway();
        });
      });
    });
  }

  void _navigateAway() {
    if (mounted) {
      _scanSequenceController.stop();
      _flowController.stop();
      _pulseController.stop();
      _vibrationController.stop();
      _rippleController.stop();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) =>
              WelcomeScreen(themeNotifier: widget.themeNotifier),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scanSequenceController.dispose();
    _flowController.dispose();
    _pulseController.dispose();
    _vibrationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF1A2F25)
        : const Color(0xFFF1F8F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 0. Ambient Particles
          AnimatedBuilder(
            animation: _flowController, // Recycle flow controller for particles
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  animationValue: _flowController.value,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                size: Size.infinite,
              );
            },
          ),

          // 1. Flow Lines
          AnimatedBuilder(
            animation: _flowController,
            builder: (context, child) {
              return CustomPaint(
                painter: EnergyFlowPainter(
                  animationValue: _flowController.value,
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  leafCount: 6,
                  radius: 140,
                ),
                size: Size.infinite,
              );
            },
          ),

          // 1.5 Alert Ripples (Only appearing behind leaves)
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              if (!_rippleController.isAnimating) {
                return const SizedBox.shrink();
              }

              final center = MediaQuery.of(context).size.center(Offset.zero);
              final sickLeafOffset = _getLeafOffset(_sickLeafIndex, 140);
              // Draw ripples at the sick leaf position
              // Note: Painter coordinates are local, so we need to center properly

              return CustomPaint(
                painter: RipplePainter(
                  animationValue: _rippleController.value,
                  color: Colors.redAccent.withValues(alpha: 0.3),
                  origin: sickLeafOffset + center,
                ),
                size: Size.infinite,
              );
            },
          ),

          // 2. Surrounding Leaves
          AnimatedBuilder(
            animation: Listenable.merge([
              _mainController,
              _pulseController,
              _vibrationController,
            ]),
            builder: (context, child) {
              return Stack(
                children: List.generate(6, (index) {
                  return _buildLeaf(index, 6, 140, theme);
                }),
              );
            },
          ),

          // 3. Central Icon
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: AppConstants.heroShadow(theme.shadowColor),
                  ),
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Image.asset(
                    'assets/icon/intelligence.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 4. Scanner Movable Overlay
          // [Scanner code remains same]
          _buildScanner(theme, 140),

          // 5. Text Titles
          _buildText(theme),
        ],
      ),
    );
  }

  Widget _buildScanner(ThemeData theme, double radius) {
    return AnimatedBuilder(
      animation: _scanSequenceController,
      builder: (context, child) {
        if (_mainController.status != AnimationStatus.completed) {
          return const SizedBox.shrink();
        }

        final pathProgress = _scanSequenceController.value;
        Offset scannerPos;
        final p0 = _getLeafOffset(_scanPathIndices[0], radius);
        final p1 = _getLeafOffset(_scanPathIndices[1], radius);
        final p2 = _getLeafOffset(_scanPathIndices[2], radius);

        if (pathProgress < 0.5) {
          final t = pathProgress / 0.5;
          final curveT = Curves.easeInOut.transform(t);
          scannerPos = Offset.lerp(p0, p1, curveT)!;
        } else {
          final t = (pathProgress - 0.5) / 0.5;
          final curveT = Curves.easeInOut.transform(t);
          scannerPos = Offset.lerp(p1, p2, curveT)!;
        }

        return Center(
          child: Transform.translate(
            offset: BufferOffset(scannerPos, -40),
            child: Transform.rotate(
              angle: -math.pi / 4,
              child: Icon(
                FontAwesomeIcons.magnifyingGlass,
                size: 64,
                color: theme.colorScheme.secondary.withValues(alpha: 0.9),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildText(ThemeData theme) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Text(
              'Leaf Guard',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset BufferOffset(Offset original, double dy) {
    return Offset(original.dx, original.dy + dy);
  }

  Widget _buildLeaf(int index, int total, double radius, ThemeData theme) {
    final angle = (index * 2 * math.pi) / total;
    final isBig = index % 2 == 0;
    final isSick = index == _sickLeafIndex;
    final baseSize = isBig ? 32.0 : 20.0;

    final animValue = _pulseController.value;
    final scaleFactor = isBig
        ? lerpDouble(0.8, 1.2, animValue)!
        : lerpDouble(1.2, 0.8, animValue)!;

    final leafColor = isSick
        ? const Color(0xFF8D6E63)
        : theme.colorScheme.primary.withValues(alpha: 0.7);

    double vibrationX = 0;
    if (isSick && _vibrationController.isAnimating) {
      vibrationX = math.sin(_vibrationController.value * math.pi * 2) * 5;
    }

    return Center(
      child: Transform.translate(
        offset: Offset(
          radius * math.cos(angle) + vibrationX,
          radius * math.sin(angle),
        ),
        child: FadeTransition(
          opacity: _leafOpacities,
          child: Transform.scale(
            scale: scaleFactor,
            child: Transform.rotate(
              angle: angle + math.pi / 2,
              child: FaIcon(
                FontAwesomeIcons.leaf,
                size: baseSize,
                color: leafColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Particle {
  double x; // 0-1
  double y; // 0-1
  double size;
  double speed;
  double theta;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.theta,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    for (var p in particles) {
      // Simple movement logic based on animationValue loop
      // We want continuous movement.
      // In a real game loop we'd use dt, here we just offset by value.

      // final dx = math.cos(p.theta) * p.speed * 0.005;
      // final dy = math.sin(p.theta) * p.speed * 0.005;

      // Update position (in a stateless painter this is tricky,
      // but we can compute position based on time if we passed real time.
      // For now, let's just draw static "floating" look by oscillating)

      final offsetX =
          size.width * p.x +
          math.sin(animationValue * 2 * math.pi + p.theta) * 10;
      final offsetY =
          size.height * p.y +
          math.cos(animationValue * 2 * math.pi + p.theta) * 10;

      canvas.drawCircle(Offset(offsetX, offsetY), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final Offset origin;

  RipplePainter({
    required this.animationValue,
    required this.color,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw 3 ripples
    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + i / 3) % 1.0;
      final radius = progress * 60; // Max radius 60
      final opacity = 1.0 - progress;

      paint.color = color.withValues(alpha: opacity * 0.5);

      canvas.drawCircle(origin, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) => true;
}

class EnergyFlowPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final int leafCount;
  final double radius;

  EnergyFlowPainter({
    required this.animationValue,
    required this.color,
    required this.leafCount,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < leafCount; i++) {
      final angle = (i * 2 * math.pi) / leafCount;
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final p1 = center;
      final p2 = endPoint;

      final dist = (p2 - p1).distance;
      final currentPos = animationValue * dist;
      final tailLength = 40.0;

      final startDist = math.max(0.0, currentPos - tailLength);
      final endDist = currentPos;

      if (startDist < dist) {
        final segmentStart = Offset(
          p1.dx + (p2.dx - p1.dx) * (startDist / dist),
          p1.dy + (p2.dy - p1.dy) * (startDist / dist),
        );

        final effectiveEndDist = math.min(dist, endDist);
        final segmentEnd = Offset(
          p1.dx + (p2.dx - p1.dx) * (effectiveEndDist / dist),
          p1.dy + (p2.dy - p1.dy) * (effectiveEndDist / dist),
        );

        paint.color = color.withValues(
          alpha: 1.0 - (effectiveEndDist / dist) * 0.5,
        );

        canvas.drawLine(segmentStart, segmentEnd, paint);
      }
    }
  }

  @override
  bool shouldRepaint(EnergyFlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
