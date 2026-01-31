import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/global_model_manager.dart';
import '../models/prediction_result.dart';
import 'image_helper.dart';

/// Data class for model predictions (internal use)
class _ModelPrediction {
  final String label;
  final double confidence;
  final int confidenceIndex;

  _ModelPrediction({
    required this.label,
    required this.confidence,
    required this.confidenceIndex,
  });
}

/// ML Service for running disease detection inference with two-stage verification
/// Stage 1: Verify if image contains a tomato leaf (using tomato_or_not_model)
/// Stage 2: If verified as tomato leaf, detect disease (using tomato_leaf_disease_model)
///
/// This service uses:
/// - GlobalModelManager for singleton model management
/// - Isolates for background image preprocessing
/// - No local model loading (uses pre-loaded global models)
class MLService {
  final GlobalModelManager _modelManager = GlobalModelManager();

  bool get isLoaded => _modelManager.isInitialized;

  /// Run two-stage prediction: first verify if it's a tomato leaf, then detect disease
  /// Returns a PredictionResult with verification status
  ///
  /// IMPORTANT: GlobalModelManager.initialize() must be called before using this method
  /// This is typically done in the splash screen
  Future<PredictionResult> predict(File imageFile) async {
    // Check if models are initialized
    if (!_modelManager.isInitialized) {
      throw Exception(
        'ML Models not initialized. Call GlobalModelManager.initialize() first.',
      );
    }

    final verificationInterpreter = _modelManager.verificationInterpreter;
    final diseaseInterpreter = _modelManager.diseaseInterpreter;

    if (verificationInterpreter == null || diseaseInterpreter == null) {
      throw Exception('ML Interpreters not available');
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final uint8ImageBytes = Uint8List.fromList(imageBytes);

      // Stage 1: Verify if image contains a tomato leaf
      final verificationResult = await _runPrediction(
        uint8ImageBytes,
        verificationInterpreter,
        _modelManager.verificationInputSize,
        _modelManager.verificationLabels,
        isVerification: true,
      );

      // The verification model returns either "Tomato Leaf" or "Not Tomato Leaf"
      final isTomatoLeaf =
          verificationResult.label.toLowerCase() == 'tomato leaf';

      if (!isTomatoLeaf) {
        // Not a tomato leaf - return early with appropriate status
        return PredictionResult(
          label: 'not_a_tomato_leaf',
          confidence: verificationResult.confidence,
          verificationStatus: VerificationStatus.notTomatoLeaf,
          verificationConfidence: verificationResult.confidence,
        );
      }

      // Stage 2: Run disease detection on verified tomato leaf
      final diseaseResult = await _runPrediction(
        uint8ImageBytes,
        diseaseInterpreter,
        _modelManager.diseaseInputSize,
        _modelManager.diseaseLabels,
        isVerification: false,
      );

      return PredictionResult(
        label: diseaseResult.label,
        confidence: diseaseResult.confidence,
        verificationStatus: VerificationStatus.isTomatoLeaf,
        verificationConfidence: verificationResult.confidence,
      );
    } catch (e) {
      throw Exception('Prediction error: ${e.toString()}');
    }
  }

  /// Internal method to run inference on a model
  /// Handles preprocessing, inference, and result extraction
  Future<_ModelPrediction> _runPrediction(
    Uint8List imageBytes,
    Interpreter interpreter,
    int inputSize,
    List<String> labels, {
    required bool isVerification,
  }) async {
    // Run preprocessing in isolate to avoid blocking UI
    final preprocessParams = PreprocessParams(
      imageBytes: imageBytes,
      inputSize: inputSize,
    );

    final preprocessResult = await Isolate.run(
      () => preprocessImageIsolate(preprocessParams),
    );

    // Run inference (fast operation, can run on main thread)
    final output = List.generate(1, (_) => List.filled(labels.length, 0.0));
    interpreter.run(preprocessResult.input4D, output);

    // Find the highest confidence prediction
    int maxIndex = 0;
    double maxConfidence = output[0][0];

    for (int i = 1; i < labels.length; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        maxIndex = i;
      }
    }

    return _ModelPrediction(
      label: labels[maxIndex],
      confidence: maxConfidence * 100,
      confidenceIndex: maxIndex,
    );
  }

  /// Dispose of resources - called when MLService is no longer needed
  /// NOTE: Do NOT dispose models here as they are managed globally
  void dispose() {
    // Models are managed by GlobalModelManager, not disposed here
  }
}
