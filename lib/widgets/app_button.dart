import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Professional styled button with solid colors
class AppButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isTonal;
  final bool isMedium;
  final bool isSmall;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isPrimary = true,
    this.isTonal = false,
    this.isMedium = false,
    this.isSmall = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: isMedium ? AppConstants.buttonMediumHeight : isSmall ? AppConstants.buttonSmallHeight : AppConstants.buttonHeight,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
            ? SizedBox(
                width: AppConstants.loaderSize,
                height: AppConstants.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppConstants.loaderStrokeWidth,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  FaIcon(icon, size: 18),
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  textAlign: TextAlign.center,
                  // style: theme.textTheme.labelSmall?.copyWith(
                  //   // color: isDark ? Colors.white70 : Colors.grey[600],
                  //   height: 1.5,
                  // ),
                ),
              ],
            ),
        ),
      );
    }

    if (isTonal) {
      final isDark = theme.brightness == Brightness.dark;
      return SizedBox(
        width: double.infinity,
        height: isMedium ? AppConstants.buttonMediumHeight : isSmall ? AppConstants.buttonSmallHeight : AppConstants.buttonHeight,
        child: FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: AppConstants.loaderSize,
                  height: AppConstants.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: AppConstants.loaderStrokeWidth,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      FaIcon(icon, size: 18),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      // style: theme.textTheme.labelSmall?.copyWith(
                      //   // color: isDark ? Colors.white70 : Colors.grey[600],
                      //   height: 1.5,
                      // ),
                    ),
                  ],
                ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: AppConstants.loaderSize,
                height: AppConstants.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppConstants.loaderStrokeWidth,
                  color: theme.colorScheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    FaIcon(icon, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}
