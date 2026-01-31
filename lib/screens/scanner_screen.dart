import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_colors.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_constants.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/global_model_manager.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';
import 'package:flutter_tomato_leaf_disease_detector/data/disease_info.dart';
import 'package:flutter_tomato_leaf_disease_detector/models/prediction_result.dart';
import 'package:flutter_tomato_leaf_disease_detector/screens/result_screen.dart';
import 'package:flutter_tomato_leaf_disease_detector/services/ml_service.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/app_button.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/custom_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tomato_leaf_disease_detector/widgets/processing_animation_widget.dart';
import 'package:flutter_tomato_leaf_disease_detector/services/scan_history_service.dart';

/// Professional scanning screen with inline workflow (No Modals)
class ScannerScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const ScannerScreen({super.key, required this.themeNotifier});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MLService _mlService = MLService();
  final ImagePicker _picker = ImagePicker();

  // Animation Controller for Pulse Effect
  late AnimationController _pulseController;

  File? _selectedImage;
  bool _isAnalyzing = false;

  bool _up = true;

  // Persistent result (for this session)
  PredictionResult? _lastResult;
  File? _lastImage;

  @override
  void initState() {
    super.initState();
    // Models are now pre-loaded in splash screen, no need to load here
    _loadLastResult();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _loadLastResult() {
    final lastScan = ScanHistoryService().lastScan;
    if (lastScan != null) {
      _lastResult = lastScan.result;
      _lastImage = lastScan.imageFile;
    }
  }

  @override
  void dispose() {
    // Do NOT dispose MLService as it uses the global manager
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
      _isAnalyzing = false; // Reset analyzing state on new image
    });
  }

  Future<void> _runInference() async {
    if (_selectedImage == null || !GlobalModelManager().isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('AI models are still loading. Please wait...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    // Artificial delay for UX (to show the analyzing animation)
    await Future.delayed(const Duration(seconds: 2));

    try {
      final result = await _mlService.predict(_selectedImage!);
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _navigateToResult(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _navigateToResult(PredictionResult result) {
    if (_selectedImage == null) return;

    final imageToPass = _selectedImage!;

    // Save to history
    ScanHistoryService().addScan(result, imageToPass);

    if (mounted) {
      setState(() {
        _lastResult = result;
        _lastImage = imageToPass;
        _selectedImage = null; // Clear selection to return to home state
      });
    }

    _pushResultScreen(result, imageToPass);
  }

  void _pushResultScreen(PredictionResult result, File image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
          imageFile: image,
          themeNotifier: widget.themeNotifier,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        themeNotifier: widget.themeNotifier,
        title: 'Leaf Guard',
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemStatusBarContrastEnforced: false,
          statusBarColor: theme.scaffoldBackgroundColor,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        sized: false,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardTheme.color : Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCard,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusLg,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/icon/icon.png",
                                color: theme.colorScheme.primary,
                                width: 32,
                                colorBlendMode: BlendMode.srcIn,
                                fit: BoxFit.contain,
                                // scale: 2,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI POWERED',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AI Diagnosis',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Analyze your crops instantly for\naccurate disease detection',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Scroll Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            //border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusLg,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Scroll to Scan',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: _up ? -5 : 0),
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeInOut,
                                onEnd: () {
                                  setState(() => _up = !_up);
                                },
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, value),
                                    child: child,
                                  );
                                },
                                child: FaIcon(
                                  FontAwesomeIcons.chevronDown,
                                  size: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                  weight: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Supported Diseases Section
                  _buildSupportedDiseases(context),

                  const SizedBox(height: 32),

                  // Detailed Guide Section
                  _buildDetailedGuide(context),

                  const SizedBox(height: 32),

                  // Last Result Section (if available)
                  if (_lastResult != null &&
                      !_isAnalyzing &&
                      _selectedImage == null) ...[
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLastResultSection(context),
                    const SizedBox(height: 32),
                  ],

                  // Main Scanner Area (Inline Workflow)
                  Text(
                    _isAnalyzing ? 'Analyzing Crop...' : 'Start Diagnosis',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Switch between Empty, Preview, and Analyzing states
                  _buildScannerArea(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLastResultSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHealthy = _lastResult?.isHealthy ?? false;

    return GestureDetector(
      onTap: () {
        if (_lastResult != null && _lastImage != null) {
          _pushResultScreen(_lastResult!, _lastImage!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? theme.cardTheme.color : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: theme.colorScheme.primary.withValues(alpha: 0.05),
          //     blurRadius: 16,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.clockRotateLeft,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Previous Scan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Thumbnail
                if (_lastImage != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusLg,
                      ),
                      image: DecorationImage(
                        image: FileImage(_lastImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lastResult?.displayLabel ?? 'Unknown',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isHealthy
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusXxs,
                          ),
                        ),
                        child: Text(
                          isHealthy ? 'Healthy' : 'Disease Detected',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isHealthy ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon (Visual only)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerArea(BuildContext context) {
    if (_isAnalyzing) {
      return _buildAnalyzingState(context);
    } else if (_selectedImage != null) {
      return _buildPreviewState(context);
    } else {
      return _buildEmptyStateCard(context);
    }
  }

  Widget _buildAnalyzingState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusHero),
      ),
      child: Column(
        children: [
          // Animated Icon
          const ProcessingAnimationWidget(size: 140),

          const SizedBox(height: 32),

          Text(
            'Running Analysis...',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Examining leaf patterns and \nidentifying potential diseases',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[600],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Linear Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 6,
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusHero),
      ),
      child: Column(
        children: [
          // Image Preview
          AspectRatio(
            aspectRatio: 1.1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radius3xl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radius3xl),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Camera',
                  icon: FontAwesomeIcons.camera,
                  isPrimary: false,
                  isTonal: true,
                  isMedium: true,
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Gallery',
                  icon: FontAwesomeIcons.image,
                  isPrimary: false,
                  isTonal: true,
                  isMedium: true,
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Analyze Crop',
            icon: FontAwesomeIcons.gears,
            onPressed: _runInference,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusHero),
        border: Border.all(color: isDark ? Colors.transparent : Colors.white),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.camera,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'No Image Selected',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a clear image of the \naffected plant leaf to get started',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[600],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons with Icons and Description
          if (!GlobalModelManager().isInitialized)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Loading AI Models...",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                _buildActionButton(
                  context,
                  title: 'Upload from Gallery',
                  subtitle: 'Choose from existing photos',
                  icon: FontAwesomeIcons.image,
                  color: isDark
                      ? AppColors.surfaceDark
                      : theme.colorScheme.primary,
                  isPrimary: true,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context,
                  title: 'Take a Photo',
                  subtitle: 'Use camera to scan directly',
                  icon: FontAwesomeIcons.camera,
                  color: isDark ? Colors.white : Colors.black87,
                  isPrimary: false,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radius3xl),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.2)
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              ),
              child: FaIcon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isPrimary
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.8)
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.6)
                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportedDiseases(BuildContext context) {
    // Use actual disease data
    final diseases = DiseaseInfo.allDiseases.toList();

    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Supported Diagnoses',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Text(
                'Can detect ${diseases.length} outcomes',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.03),
            //  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: diseases.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Container(
                  width: 170,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme
                        .cardTheme
                        .color, // diseases[index].isHealthy ? theme.primaryColor.withValues(alpha: 0.06) : theme.colorScheme.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppConstants.radius3xl),
                    border: Border.all(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          diseases[index].isHealthy
                              ? 'assets/icon/leaf-healthy.png'
                              : diseases[index].isOther
                              ? 'assets/icon/dont-know.png'
                              : diseases[index].isInvalid
                              ? 'assets/icon/hypothesis.png'
                              : 'assets/icon/leaf-sick.png',
                          width: 40,
                          color: diseases[index].isOther
                              ? theme.colorScheme.primary
                              : diseases[index].isInvalid
                              ? theme.colorScheme.primary
                              : null,
                          colorBlendMode: BlendMode.srcIn,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        diseases[index].name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: AppConstants.buttonSmallHeight,
                        child: TextButton(
                          onPressed: () =>
                              _showDiseaseDetails(context, diseases[index]),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: .9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusLg,
                              ),
                            ),
                            minimumSize: Size.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              "Read More",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedGuide(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: isDark ? Colors.transparent : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.lightbulb,
                  size: 20,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Practices',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Follow for 99% accuracy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildGuideStep(
            context,
            '1',
            'Ensure Good Lighting',
            'Avoid shadows or extreme brightness on the leaf.',
          ),
          const SizedBox(height: 16),
          _buildGuideStep(
            context,
            '2',
            'Focus on Symptoms',
            'Get close to the spots, holes, or discoloration.',
          ),
          const SizedBox(height: 16),
          _buildGuideStep(
            context,
            '3',
            'Steady Camera',
            'Hold the phone steady to avoid blur.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(
    BuildContext context,
    String number,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDiseaseDetails(BuildContext context, DiseaseInfo disease) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        IconData typeIcon;
        Color typeColor;
        String typeName;
        String typeImage;

        switch (disease.type) {
          case DiseaseType.virus:
            typeIcon = FontAwesomeIcons.virus;
            typeColor = DiseaseType.virus.typeColor;
            typeName = DiseaseType.virus.typeName;
            typeImage = DiseaseType.virus.iconPath;
            break;
          case DiseaseType.bacteria:
            typeIcon = FontAwesomeIcons.bacterium;
            typeColor = DiseaseType.bacteria.typeColor;
            typeName = DiseaseType.bacteria.typeName;
            typeImage = DiseaseType.bacteria.iconPath;
            break;
          case DiseaseType.fungus:
            typeIcon = FontAwesomeIcons.spaghettiMonsterFlying;
            typeIcon = FontAwesomeIcons.circleNodes;
            typeColor = DiseaseType.fungus.typeColor;
            typeName = DiseaseType.fungus.typeName;
            typeImage = DiseaseType.fungus.iconPath;
            break;
          case DiseaseType.pest:
            typeIcon = FontAwesomeIcons.spider;
            typeColor = DiseaseType.pest.typeColor;
            typeName = DiseaseType.pest.typeName;
            typeImage = DiseaseType.pest.iconPath;
            break;
          case DiseaseType.healthy:
            typeIcon = FontAwesomeIcons.heart;
            typeColor = DiseaseType.healthy.typeColor;
            typeName = DiseaseType.healthy.typeName;
            typeImage = DiseaseType.healthy.iconPath;
            break;
          case DiseaseType.other:
            typeIcon = FontAwesomeIcons.heart;
            typeColor = DiseaseType.other.typeColor;
            typeName = DiseaseType.other.typeName;
            typeImage = DiseaseType.other.iconPath;
            break;
          default:
            typeIcon = FontAwesomeIcons.circleQuestion;
            typeColor = DiseaseType.invalid.typeColor;
            typeName = DiseaseType.invalid.typeName;
            typeImage = DiseaseType.invalid.iconPath;
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Image/Icon
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              typeImage,
                              width: 42,
                              color: DiseaseType.other == disease.type
                                  ? theme.colorScheme.primary
                                  : DiseaseType.invalid == disease.type
                                  ? theme.colorScheme.primary
                                  : null,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                            // child: FaIcon(typeIcon, size: 32, color: typeColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          disease.name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: typeColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(typeIcon, size: 12, color: typeColor),
                              const SizedBox(width: 8),
                              Text(
                                typeName,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // About Section with Background
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[800]!
                                : Colors.grey[200]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.circleInfo,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'About',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              disease.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                height: 1.6,
                                // fontWeight: FontWeight.w400
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Common Causes Section with Background
                      if (disease.causes.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: typeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: FaIcon(
                                      (disease.type == DiseaseType.healthy)
                                          ? FontAwesomeIcons.marker
                                          : FontAwesomeIcons
                                                .triangleExclamation,
                                      size: 14,
                                      color: typeColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    (disease.type == DiseaseType.healthy)
                                        ? 'Helpful Recommendations'
                                        : 'Common Causes',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...disease.causes.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: typeColor.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: typeColor.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: typeColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 3,
                                          ),
                                          child: Text(
                                            entry.value,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: isDark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                                  height: 1.4,
                                                  // fontWeight: FontWeight.w500
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Opacity(
                  opacity: .85,
                  child: AppButton(
                    text: 'Close',
                    onPressed: () => Navigator.pop(context),
                    isPrimary: true,
                    isTonal: false,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
