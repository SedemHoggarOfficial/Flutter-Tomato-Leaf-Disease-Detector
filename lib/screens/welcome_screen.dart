import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/screens/scanner_screen.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/app_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Professional welcome screen with clean white background
class WelcomeScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const WelcomeScreen({super.key, required this.themeNotifier});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
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
      body: Stack(
        children: [
          // Background decorative elements
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top bar with theme toggle
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => widget.themeNotifier.toggleTheme(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingLg,
                              vertical: AppConstants.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusThemeToggle,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  isDark
                                      ? FontAwesomeIcons.moon
                                      : FontAwesomeIcons.sun,
                                  size: 14,
                                  color: isDark ? Colors.black : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDark ? 'Dark' : 'Light',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.black
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Hero Section
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.leaf,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title
                      Text(
                        'Plant Disease\nDetector',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
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
        ],
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
