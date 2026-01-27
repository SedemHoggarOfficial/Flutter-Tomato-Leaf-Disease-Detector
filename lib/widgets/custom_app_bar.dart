import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/theme_toggle.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget{
  final ThemeNotifier themeNotifier;

  final String? title;
  final bool hasBackButton;

  const CustomAppBar({
    super.key, 
    required this.themeNotifier,
    this.title,
    this.hasBackButton = true,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: widget.title != null ? Text(
        widget.title!,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ) : null,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: widget.hasBackButton ? Padding(
        padding: const EdgeInsets.only(left: 16),
        child: IconButton(
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
      ) : null,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ThemeToggle(themeNotifier: widget.themeNotifier),
        ),
      ],
    );
  }
}