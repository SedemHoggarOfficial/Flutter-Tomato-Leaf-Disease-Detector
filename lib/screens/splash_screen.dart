import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/screens/welcome_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  // in the bottom sheet, make the about more detailed. and the common causes, make the bullet points more like numbered with squares around them. make each section have a background. keep everything professional

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _leafOpacities;

  // Configuration
  final int _sickLeafIndex = 2;
  final List<int> _scanPathIndices = [0, 4, 2];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();

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
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _vibrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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

        Future.delayed(const Duration(milliseconds: 2000), () {
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: theme.scaffoldBackgroundColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        sized: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Flow Lines
            AnimatedBuilder(
              animation: _flowController,
              builder: (context, child) {
                return CustomPaint(
                  painter: EnergyFlowPainter(
                    animationValue: _flowController.value,
                    color: const Color(0xFF00E5FF), // Cyan "current" color
                    leafCount: 6,
                    radius: AppConstants.splashScreenRadius,
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
                    return _buildLeaf(index, 6, AppConstants.splashScreenRadius, theme);
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
                    width: 70,
                    height: 70,
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
            _buildScanner(theme, AppConstants.splashScreenRadius),
        
            // 5. Text Titles
            _buildText(theme),
          ],
        ),
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
            offset: scannerPos,
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
      bottom: 27,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Text(
              'Leaf Guard',
              style: TextStyle(
                fontFamily: 'RobotoSlab',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaf(int index, int total, double radius, ThemeData theme) {
    final angle = (index * 2 * math.pi) / total;
    final isSick = index == _sickLeafIndex;

    final animValue = _pulseController.value;
    final scaleFactor = lerpDouble(0.9, 1.1, animValue)!;

    // Unified color or just use image
    // final leafColor = theme.colorScheme.primary.withOpacity(0.7);

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
              angle: 0,
              child: Image.asset(
                isSick
                    ? 'assets/icon/leaf-sick.png'
                    : 'assets/icon/leaf-healthy.png',
                width: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    
    // Draw dashed lines and pulses
    for (int i = 0; i < leafCount; i++) {
      final angle = (i * 2 * math.pi) / leafCount;
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      // Draw faint dashed line background
      _drawDashedLine(canvas, center, endPoint, color.withOpacity(0.1), width: 1.0);

      // Draw pulse as a DASHED segment
      final dist = (endPoint - center).distance;
      final packetSize = 50.0;
      final progressIdx = (animationValue * (dist + packetSize)); // Allow it to flow fully out
      
      final p1 = center;
      final p2 = endPoint;
      
      // Calculate start and end of the packet
      final packetEnd = progressIdx;
      final packetStart = packetEnd - packetSize;
            
      // We clip the segment to the line 0..dist
      final validStart = math.max(0.0, packetStart);
      final validEnd = math.min(dist, packetEnd);
      
      if (validStart < validEnd) {
         final startOffset = _lerpOffset(p1, p2, validStart / dist);
         final endOffset = _lerpOffset(p1, p2, validEnd / dist);
         
         // Draw the pulse using dashes too, but thicker/brighter
         _drawDashedLine(canvas, startOffset, endOffset, color, width: 2.5);
      }
    }
  }

  Offset _lerpOffset(Offset a, Offset b, double t) {
    return Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Color color, {double width = 1.0}) {
     final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
     final dist = (p2 - p1).distance;
     final dashWidth = 6.0;
     final dashSpace = 4.0;
     double currentDist = 0.0;
     
     while (currentDist < dist) {
       final start = _lerpOffset(p1, p2, currentDist / dist);
       final endDist = math.min(dist, currentDist + dashWidth);
       final end = _lerpOffset(p1, p2, endDist / dist);
       
       canvas.drawLine(start, end, paint);
       currentDist += dashWidth + dashSpace;
     }
  }
  @override
  bool shouldRepaint(EnergyFlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
