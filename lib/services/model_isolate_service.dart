import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Data class for model file bytes passed to isolate
class _ModelFileBytes {
  final String modelPath;
  final Uint8List bytes;

  _ModelFileBytes({required this.modelPath, required this.bytes});
}

/// Data class for model initialization parameters
class ModelInitParams {
  final String modelPath;
  final String labelsPath;

  ModelInitParams({required this.modelPath, required this.labelsPath});
}

/// Data class for model initialization result (contains only input size)
class ModelInitResult {
  final String modelPath;
  final String labelsPath;
  final int inputSize;
  final List<String> labels;

  ModelInitResult({
    required this.modelPath,
    required this.labelsPath,
    required this.inputSize,
    required this.labels,
  });
}

/// Result from isolate (doesn't include labels - they load in main thread)
class _IsolateModelResult {
  final String modelPath;
  final int inputSize;

  _IsolateModelResult({required this.modelPath, required this.inputSize});
}

/// Service for initializing ML models in a background isolate
/// This prevents blocking the main thread during model loading
class ModelIsolateService {
  /// Initialize a single model in background isolate
  /// Labels and model bytes are loaded in main thread (requires Flutter binding)
  static Future<ModelInitResult> initializeModelInIsolate(
    ModelInitParams params,
  ) async {
    // Load labels and model bytes in main thread (has access to rootBundle)
    final labels = await _loadLabels(params.labelsPath);
    final modelBytes = await _loadModelBytes(params.modelPath);

    // Initialize model in isolate (no binding needed)
    final isolateResult = await Isolate.run(
      () => _modelInitializationRoutine(modelBytes),
    );

    return ModelInitResult(
      modelPath: params.modelPath,
      labelsPath: params.labelsPath,
      inputSize: isolateResult.inputSize,
      labels: labels,
    );
  }

  /// Initialize both models in parallel using multiple isolates
  /// Returns both results simultaneously for optimal performance
  static Future<(ModelInitResult, ModelInitResult)>
  initializeBothModelsParallel(
    ModelInitParams verificationParams,
    ModelInitParams diseaseParams,
  ) async {
    // Load labels in parallel in main thread
    final verificationLabels = _loadLabels(verificationParams.labelsPath);
    final diseaseLabels = _loadLabels(diseaseParams.labelsPath);

    // Load model bytes in parallel in main thread
    final verificationBytes = _loadModelBytes(verificationParams.modelPath);
    final diseaseBytes = _loadModelBytes(diseaseParams.modelPath);

    // Create futures for model initialization in isolates
    // We need to await the bytes first, then pass them
    final verificationBytesData = await verificationBytes;
    final diseaseBytesData = await diseaseBytes;

    final verificationFuture = Isolate.run(
      () => _modelInitializationRoutine(verificationBytesData),
    );

    final diseaseFuture = Isolate.run(
      () => _modelInitializationRoutine(diseaseBytesData),
    );

    // Wait for all operations
    final labels = await Future.wait([verificationLabels, diseaseLabels]);
    final models = await Future.wait([verificationFuture, diseaseFuture]);

    return (
      ModelInitResult(
        modelPath: verificationParams.modelPath,
        labelsPath: verificationParams.labelsPath,
        inputSize: models[0].inputSize,
        labels: labels[0],
      ),
      ModelInitResult(
        modelPath: diseaseParams.modelPath,
        labelsPath: diseaseParams.labelsPath,
        inputSize: models[1].inputSize,
        labels: labels[1],
      ),
    );
  }

  /// Load labels from assets (main thread only - requires rootBundle)
  static Future<List<String>> _loadLabels(String labelsPath) async {
    try {
      final labelsData = await rootBundle.loadString(labelsPath);
      final labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return labels;
    } catch (e) {
      rethrow;
    }
  }

  /// Load model file bytes from assets (main thread only - requires rootBundle)
  static Future<_ModelFileBytes> _loadModelBytes(String modelPath) async {
    try {
      final byteData = await rootBundle.load(modelPath);
      return _ModelFileBytes(
        modelPath: modelPath,
        bytes: byteData.buffer.asUint8List(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Actual model initialization routine to run in isolate
  /// This function executes in a separate thread
  /// NOTE: Model bytes are pre-loaded in main thread, no binding needed here
  static Future<_IsolateModelResult> _modelInitializationRoutine(
    _ModelFileBytes modelFileBytes,
  ) async {
    try {
      // Load interpreter from bytes (no binding needed)
      final interpreter = await Interpreter.fromBuffer(
        modelFileBytes.bytes,
        options: InterpreterOptions()
          ..threads = 4
          ..useNnApiForAndroid = false,
      );

      // Get input size from model
      final inputTensor = interpreter.getInputTensor(0);
      final inputSize = inputTensor.shape[1];

      // Close interpreter (we'll recreate it in main thread)
      interpreter.close();

      return _IsolateModelResult(
        modelPath: modelFileBytes.modelPath,
        inputSize: inputSize,
      );
    } catch (e) {
      rethrow;
    }
  }
}
