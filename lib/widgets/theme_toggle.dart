import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ThemeToggle extends StatefulWidget {
  const ThemeToggle({super.key, required this.themeNotifier});

  final ThemeNotifier themeNotifier;

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
        onTap: () => widget.themeNotifier.toggleTheme(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingSm,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(
              AppConstants.radiusThemeToggle,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                isDark ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
                size: 14,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                isDark ? 'Dark' : 'Light',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
  }
}