import 'dart:io';
import 'package:flutter_tomato_leaf_disease_detector/models/prediction_result.dart';

class ScanRecord {
  final PredictionResult result;
  final File imageFile;
  final DateTime timestamp;

  ScanRecord({
    required this.result,
    required this.imageFile,
    required this.timestamp,
  });
}

class ScanHistoryService {
  static final ScanHistoryService _instance = ScanHistoryService._internal();

  factory ScanHistoryService() {
    return _instance;
  }

  ScanHistoryService._internal();

  final List<ScanRecord> _history = [];

  List<ScanRecord> get history => List.unmodifiable(_history);

  ScanRecord? get lastScan => _history.isNotEmpty ? _history.last : null;

  void addScan(PredictionResult result, File imageFile) {
    _history.add(
      ScanRecord(
        result: result,
        imageFile: imageFile,
        timestamp: DateTime.now(),
      ),
    );
  }

  void clearHelper() {
    _history.clear();
  }
}
