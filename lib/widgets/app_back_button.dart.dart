import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBackButton extends StatefulWidget {
  const AppBackButton({super.key, required this.themeNotifier});

  final ThemeNotifier themeNotifier;

  @override
  State<AppBackButton> createState() => _AppBackButtonState();
}

class _AppBackButtonState extends State<AppBackButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double width = 37;
    final double height = 37;
    // final isDark = theme.brightness == Brightness.dark;
    
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(maxWidth: width,maxHeight: height),
      icon: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.9),
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
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}