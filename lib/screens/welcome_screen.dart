import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/screens/scanner_screen.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/app_button.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/theme_toggle.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional welcome screen with clean white background
class WelcomeScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const WelcomeScreen({super.key, required this.themeNotifier});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool startPulse = false;
  bool animate = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween(begin: 0.2, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().whenComplete((){
      startPulse = true;
      _controller.dispose();

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      );

      _scaleAnimation = Tween(begin: 0.97, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );

      _controller.repeat(reverse: true);
      setState(() {});

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? theme.cardTheme.color : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.chevronLeft,
                size: 16,
                color: theme.iconTheme.color,
              ),
            ),
          ),
        ),
        actions: [
          ThemeToggle(themeNotifier: widget.themeNotifier),
          const SizedBox(width: 24),
        ]
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Opacity(
                          opacity: isDark ? 0.75 : 0.9,
                          child: Image.asset(
                            'assets/icon/intelligence.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'LEAF GUARD',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      // letterSpacing: 1.2,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tomato Leaf Plant Disease Detector',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.6,
                      ),
                      height: 1.2,
                    ),
                  ),
      
                  const SizedBox(height: 16),
      
                  // Description
                  Text(
                    'Intelligent AI-powered analysis for your crops. Detect diseases instantly and get expert treatment advice.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                      height: 1.5,
                    ),
                  ),
      
                  const SizedBox(height: 48),
      
                  // Features List
                  _buildFeatureItem(
                    context,
                    icon: FontAwesomeIcons.bolt,
                    title: 'Instant Analysis',
                    subtitle: 'Get results in seconds',
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureItem(
                    context,
                    icon: FontAwesomeIcons.microscope,
                    title: '98% Accuracy',
                    subtitle: 'Powered by advanced AI',
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureItem(
                    context,
                    icon: FontAwesomeIcons.bookOpen,
                    title: 'Expert Care Tips',
                    subtitle: 'Detailed treatment guides',
                  ),
      
                  const Spacer(),
      
                  // Start Button
                  AppButton(
                    text: 'Start Scanning',
                    icon: FontAwesomeIcons.camera,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScannerScreen(
                            themeNotifier: widget.themeNotifier,
                          ),
                        ),
                      );
                    },
                  ),
      
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppConstants.radius3xl),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
