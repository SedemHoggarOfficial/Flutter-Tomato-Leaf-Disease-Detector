import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Premium scanning overlay with advanced animations
class ScanningOverlay extends StatefulWidget {
  const ScanningOverlay({super.key});

  @override
  State<ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<ScanningOverlay>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Simple static icon instead of glowing orb
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.microscope,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Status text (No shader mask)
              Text(
                'Analyzing Disease',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'AI is scanning your plant for diseases',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              // Progress steps (Simplified)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 48),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildProgressStep(
                      context,
                      icon: FontAwesomeIcons.image,
                      text: 'Processing Image',
                      isActive: true,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressStep(
                      context,
                      icon: FontAwesomeIcons.brain,
                      text: 'Running AI Analysis',
                      isActive: true,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressStep(
                      context,
                      icon: FontAwesomeIcons.clipboardCheck,
                      text: 'Generating Results',
                      isActive: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool isActive,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: isActive
                  ? theme.colorScheme.primary
                  : Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isActive
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : FaIcon(
                    icon,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
