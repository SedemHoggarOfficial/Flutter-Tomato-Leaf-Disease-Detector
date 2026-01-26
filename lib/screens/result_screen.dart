import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/models/prediction_result.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/app_button.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/result_card.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/theme_toggle.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Premium result screen with hero animation and detailed disease info
class ResultScreen extends StatefulWidget {
  final PredictionResult result;
  final File imageFile;
  final ThemeNotifier themeNotifier;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
    required this.themeNotifier,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHealthy = widget.result.isHealthy;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: isHealthy
                ? theme.colorScheme.primary
                : widget.result.isUncertain
                ? const Color(0xFF616161)
                : const Color(0xFFc62828),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              ThemeToggle(themeNotifier: widget.themeNotifier),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with gradient overlay
                  Hero(
                    tag: widget.imageFile.path,
                    child: Image.file(widget.imageFile, fit: BoxFit.cover),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Status badge at bottom
                  Positioned(
                    bottom: 16,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isHealthy
                                ? isDark ? theme.colorScheme.onPrimary.withValues(alpha: 0.9) : theme.colorScheme.primary.withValues(alpha: 0.9)
                                : widget.result.isUncertain
                                ? Colors.grey.withValues(alpha: 0.9)
                                : Colors.red.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusXs,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                isHealthy
                                    ? FontAwesomeIcons.shieldHeart
                                    : widget.result.isUncertain
                                    ? FontAwesomeIcons.circleQuestion
                                    : FontAwesomeIcons.triangleExclamation,
                                size: 12,
                                color: theme.colorScheme.onError
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isHealthy
                                    ? 'HEALTHY CROP'
                                    : widget.result.isUncertain
                                    ? 'UNCERTAIN'
                                    : 'ISSUE DETECTED',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusXs,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.chartPie,
                                size: 10,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${(widget.result.confidence).toStringAsFixed(1)}% Match',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Result card
                      ResultCard(result: widget.result),

                      const SizedBox(height: 32),

                      // Quick Actions Header
                      Text(
                        'What would you like to do?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
                      AppButton(
                        text: 'Scan Another Plant',
                        icon: FontAwesomeIcons.camera,
                        onPressed: () => Navigator.of(context).pop(),
                      ),

                      const SizedBox(height: 12),

                      AppButton(
                        text: 'Back to Home',
                        //icon: FontAwesomeIcons.chevronLeft,
                        isPrimary: false,
                        isTonal: true,
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Disclaimer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Color.fromARGB(255, 206, 127, 8) : Color(0XFFFF9800),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radius3xl,
                          ),
                          border: Border.all(
                            width: 3,
                            color: Colors.amberAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.circleInfo,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This is an AI-powered analysis. For accurate diagnosis, please consult with an agricultural expert.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  height: 1.4,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
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
}
