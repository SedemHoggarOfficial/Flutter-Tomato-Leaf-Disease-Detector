import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/global_model_manager.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const SplashScreen({super.key, required this.themeNotifier});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  bool _modelsLoaded = false;
  bool _modelLoadingError = false;
  String _modelLoadingErrorMessage = '';
  bool _animationComplete = false;
  final Duration _minimumSplashDuration = const Duration(seconds: 5);
  late DateTime _splashStartTime;

  @override
  void initState() {
    super.initState();
    _splashStartTime = DateTime.now();
    _initializeAnimation();
    _loadModels();
  }

  void _initializeAnimation() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _floatAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.1, end: 0.25).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _scaleController.forward().then((_) {
      if (mounted) {
        setState(() => _animationComplete = true);
        _floatController.repeat(reverse: true);
        _rotationController.repeat(reverse: true);
        _glowController.repeat(reverse: true);
        _checkAndNavigate();
      }
    });
  }

  Future<void> _loadModels() async {
    try {
      final success = await GlobalModelManager().initialize();

      if (mounted) {
        if (success) {
          setState(() => _modelsLoaded = true);
          _checkAndNavigate();
        } else {
          throw GlobalModelManager().initializationError ??
              Exception('Failed to initialize models');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _modelLoadingError = true;
          _modelLoadingErrorMessage = e.toString();
        });
        _showErrorDialog();
      }
    }
  }

  void _checkAndNavigate() {
    // Only navigate when BOTH conditions are met AND minimum time has passed
    if (_animationComplete && _modelsLoaded && !_modelLoadingError) {
      final elapsedTime = DateTime.now().difference(_splashStartTime);
      final remainingTime = _minimumSplashDuration - elapsedTime;

      if (remainingTime.isNegative) {
        // Minimum time already passed, navigate immediately
        if (mounted) {
          _navigateToWelcome();
        }
      } else {
        // Wait for remaining time
        Future.delayed(remainingTime, () {
          if (mounted) {
            _navigateToWelcome();
          }
        });
      }
    }
  }

  void _navigateToWelcome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            WelcomeScreen(themeNotifier: widget.themeNotifier),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Loading Error'),
        content: Text(_modelLoadingErrorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAndRetry();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _resetAndRetry() {
    setState(() {
      _modelsLoaded = false;
      _modelLoadingError = false;
      _animationComplete = false;
    });
    _scaleController.reset();
    _initializeAnimation();
    _loadModels();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _floatController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1419) : const Color(0xFFFAFBFC);
    final accentColor = const Color(0xFF00C853);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: bgColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: bgColor,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon with floating effect
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _scaleAnimation,
                      _floatAnimation,
                      _rotationAnimation,
                      _glowAnimation,
                    ]),
                    builder: (context, _) {
                      // Floating effect - subtle vertical movement
                      final floatOffset = (_floatAnimation.value - 0.5) * 12;

                      // Subtle rotation
                      final rotation = _rotationAnimation.value;

                      return Transform.translate(
                        offset: Offset(0, floatOffset),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Transform.rotate(
                            angle: rotation,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFF00C853,
                                ).withOpacity(0.08),
                                border: Border.all(
                                  color: const Color(
                                    0xFF00C853,
                                  ).withOpacity(0.15),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00C853,
                                    ).withOpacity(_glowAnimation.value),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/icon/intelligence.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Title
                  // Text(
                  //   'TomatoScan',
                  //   style: theme.textTheme.headlineSmall?.copyWith(
                  //     fontWeight: FontWeight.w600,
                  //     color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  //     letterSpacing: 0.5,
                  //   ),
                  // ),
                  Text(
                    'Leaf Guard',
                    style: TextStyle(
                      fontFamily: 'RobotoSlab',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'AI Leaf Disease Detection',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading indicator
                  if (!_modelLoadingError)
                    Column(
                      children: [
                        SizedBox(
                          width: 2,
                          height: 24,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha:0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.4, end: 1.0)
                                  .animate(
                                    CurvedAnimation(
                                      parent: _scaleController,
                                      curve: const Interval(
                                        0.5,
                                        1.0,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  ),
                              alignment: Alignment.bottomCenter,
                              child: Container(color: accentColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _modelsLoaded ? 'Ready' : 'Loading',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _modelsLoaded
                                ? accentColor
                                : (isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[500]),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
