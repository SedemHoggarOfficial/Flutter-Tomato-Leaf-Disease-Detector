import 'package:tflite_flutter/tflite_flutter.dart';

import '../services/model_isolate_service.dart';

/// Global singleton instance for managing ML model lifecycle
/// Ensures models are loaded once and reused throughout the app
class GlobalModelManager {
  static final GlobalModelManager _instance = GlobalModelManager._internal();

  factory GlobalModelManager() {
    return _instance;
  }

  GlobalModelManager._internal();

  // Model state
  Interpreter? _verificationInterpreter;
  Interpreter? _diseaseInterpreter;
  List<String> _verificationLabels = [];
  List<String> _diseaseLabels = [];
  int _verificationInputSize = 0;
  int _diseaseInputSize = 0;
  bool _isInitialized = false;
  bool _isInitializing = false;
  Exception? _initializationError;

  // Getters for model state
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  Exception? get initializationError => _initializationError;

  Interpreter? get verificationInterpreter => _verificationInterpreter;
  Interpreter? get diseaseInterpreter => _diseaseInterpreter;
  List<String> get verificationLabels => _verificationLabels;
  List<String> get diseaseLabels => _diseaseLabels;
  int get verificationInputSize => _verificationInputSize;
  int get diseaseInputSize => _diseaseInputSize;

  /// Initialize both ML models in parallel using isolates
  /// This should be called once during app startup (preferably in splash screen)
  /// Returns true if initialization successful, false otherwise
  Future<bool> initialize() async {
    // Prevent multiple simultaneous initialization attempts
    if (_isInitializing) {
      // Wait for ongoing initialization
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _isInitialized;
    }

    if (_isInitialized) {
      return true;
    }

    _isInitializing = true;
    _initializationError = null;

    try {
      // Initialize both models in parallel using isolates
      final (
        verificationResult,
        diseaseResult,
      ) = await ModelIsolateService.initializeBothModelsParallel(
        ModelInitParams(
          modelPath: 'assets/models/tomato_or_not_model.tflite',
          labelsPath: 'assets/models/tomato_or_not_model_labels.txt',
        ),
        ModelInitParams(
          modelPath: 'assets/models/tomato_leaf_disease_model.tflite',
          labelsPath: 'assets/models/tomato_leaf_disease_model_labels.txt',
        ),
      );

      // Store results from isolate
      _verificationInputSize = verificationResult.inputSize;
      _verificationLabels = verificationResult.labels;
      _diseaseInputSize = diseaseResult.inputSize;
      _diseaseLabels = diseaseResult.labels;

      // Load interpreters in main thread (fast operation after models are prepared)
      await _loadInterpretersInMainThread();

      _isInitialized = true;
      return true;
    } catch (e) {
      _isInitialized = false;
      _initializationError = Exception('Model initialization failed: $e');
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Load interpreter instances in main thread
  /// (Interpreters must be created in the main thread that uses them)
  Future<void> _loadInterpretersInMainThread() async {
    _verificationInterpreter = await Interpreter.fromAsset(
      'assets/models/tomato_or_not_model.tflite',
      options: InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false,
    );

    _diseaseInterpreter = await Interpreter.fromAsset(
      'assets/models/tomato_leaf_disease_model.tflite',
      options: InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false,
    );
  }

  /// Dispose of all model resources
  /// Call this when app is closing
  void dispose() {
    _verificationInterpreter?.close();
    _verificationInterpreter?.close();
    _diseaseInterpreter?.close();
    _verificationInterpreter = null;
    _diseaseInterpreter = null;
    _isInitialized = false;
  }

  /// Reset initialization state (useful for testing)
  void reset() {
    dispose();
    _initializationError = null;
  }
}
