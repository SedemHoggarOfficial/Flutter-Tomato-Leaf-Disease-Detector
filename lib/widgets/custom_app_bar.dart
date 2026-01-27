import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/app_back_button.dart.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/theme_toggle.dart';

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
    // final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Container(
        height: kToolbarHeight,
        decoration: BoxDecoration(
          color: Colors.transparent
        ),
        padding: EdgeInsets.symmetric(horizontal: 16),
        // margin: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.hasBackButton ? AppBackButton(themeNotifier: widget.themeNotifier) : SizedBox(width: 0),
    
            widget.title != null ? Text(
              widget.title!,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ) : SizedBox(width: 0),
            ThemeToggle(themeNotifier: widget.themeNotifier),
          ],
        ),
      ),
    );
  }
}