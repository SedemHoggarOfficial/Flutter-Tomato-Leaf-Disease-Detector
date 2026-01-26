import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/prediction_result.dart';
import 'image_helper.dart';

/// ML Service for running disease detection inference
/// Uses isolates for background image preprocessing
class MLService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  late int _inputSize;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  int get inputSize => _inputSize;

  /// Initialize the ML model and labels
  Future<void> initialize() async {
    if (_isLoaded) return;

    // Load the TFLite model
    _interpreter = await Interpreter.fromAsset(
      'assets/model.tflite',
      options: InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = false,
    );

    // Get input size from model
    final inputTensor = _interpreter!.getInputTensor(0);
    _inputSize = inputTensor.shape[1];

    // Load labels
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    _labels = labelsData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    _isLoaded = true;
  }

  /// Run prediction on an image file
  /// Returns only the highest confidence result
  Future<PredictionResult> predict(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      throw Exception('ML Service not initialized');
    }

    // Read image bytes
    final imageBytes = await imageFile.readAsBytes();

    // Run preprocessing in isolate to avoid blocking UI
    final preprocessParams = PreprocessParams(
      imageBytes: imageBytes,
      inputSize: _inputSize,
    );

    final preprocessResult = await Isolate.run(
      () => preprocessImageIsolate(preprocessParams),
    );

    // Run inference (this is fast and can run on main thread)
    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    _interpreter!.run(preprocessResult.input4D, output);

    // Find the highest confidence prediction
    int maxIndex = 0;
    double maxConfidence = output[0][0];

    for (int i = 1; i < _labels.length; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        maxIndex = i;
      }
    }

    return PredictionResult(
      label: _labels[maxIndex],
      confidence: maxConfidence * 100,
    );
  }

  /// Dispose of resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
