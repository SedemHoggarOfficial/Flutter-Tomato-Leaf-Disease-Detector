import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_colors.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:flutter_tomato_leaf_disease_detector/data/disease_info.dart';
import 'package:flutter_tomato_leaf_disease_detector/models/prediction_result.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Premium result card with animated confidence and expandable sections
class ResultCard extends StatefulWidget {
  final PredictionResult result;

  const ResultCard({super.key, required this.result});

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _causesExpanded = true;
  bool _solutionsExpanded = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation =
        Tween<double>(begin: 0, end: widget.result.confidence / 100).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diseaseInfo = DiseaseInfo.getInfo(widget.result.label);
    final isHealthy = widget.result.isHealthy;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppConstants.radius3xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disease name header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isHealthy
                              ? [
                                  const Color(0xFF66BB6A),
                                  const Color(0xFF66BB6A),
                                ]
                              : widget.result.isUncertain
                              ? [
                                  const Color(0xFF757575),
                                  const Color(0xFF757575),
                                ]
                              : [
                                  const Color(0xFFE53935),
                                  const Color(0xFFE53935),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusLg,
                        ),
                      ),
                      child: FaIcon(
                        isHealthy
                            ? FontAwesomeIcons.leaf
                            : widget.result.isUncertain
                            ? FontAwesomeIcons.question
                            : FontAwesomeIcons.virus,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.result.displayLabel,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (diseaseInfo != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              diseaseInfo.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Confidence meter
                _buildConfidenceMeter(context),
              ],
            ),
          ),

          if (diseaseInfo != null) ...[
            const Divider(height: 1),

            // Causes section (expandable)
            _buildExpandableSection(
              context,
              title: isHealthy ? 'Current Status' : 'Possible Causes',
              icon: isHealthy
                  ? FontAwesomeIcons.heartPulse
                  : FontAwesomeIcons.magnifyingGlass,
              iconColor: isHealthy ? Colors.green : Colors.orange,
              items: diseaseInfo.causes,
              isExpanded: _causesExpanded,
              onToggle: () =>
                  setState(() => _causesExpanded = !_causesExpanded),
            ),

            const Divider(height: 1),

            // Solutions section (expandable)
            _buildExpandableSection(
              context,
              title: isHealthy ? 'Care Tips' : 'Recommended Solutions',
              icon: FontAwesomeIcons.lightbulb,
              iconColor: theme.colorScheme.primary,
              items: diseaseInfo.solutions,
              isExpanded: _solutionsExpanded,
              onToggle: () =>
                  setState(() => _solutionsExpanded = !_solutionsExpanded),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceMeter(BuildContext context) {
    final theme = Theme.of(context);
    final confidence = widget.result.confidence;

    Color getConfidenceColor() {
      if (confidence >= 80) return AppColors.confidenceHigh;
      if (confidence >= 60) return AppColors.confidenceMedium;
      return AppColors.confidenceLow;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.chartLine,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Confidence Level',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progressAnimation.value * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: getConfidenceColor(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 12,
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusXs,
                      ),
                    ),
                  ),
                  // Progress
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            getConfidenceColor().withValues(alpha: 0.8),
                            getConfidenceColor(),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildConfidenceLabel(context, 'Low', AppColors.confidenceLow),
            _buildConfidenceLabel(context, 'Medium', AppColors.confidenceMedium),
            _buildConfidenceLabel(context, 'High', AppColors.confidenceHigh),
          ],
        ),
      ],
    );
  }

  Widget _buildConfidenceLabel(BuildContext context, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Header (tappable)
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: FaIcon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 2),
                      Text(
                        '${items.length} items',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.06,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.chevronDown,
                      size: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == items.length - 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Number badge - properly centered
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusSm,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Text content
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.85,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
