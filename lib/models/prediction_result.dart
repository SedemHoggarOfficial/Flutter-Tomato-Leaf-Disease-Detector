/// Represents the result of a disease prediction
class PredictionResult {
  final String label;
  final double confidence;
  final bool isHealthy;

  PredictionResult({
    required this.label,
    required this.confidence,
  }) : isHealthy = label.toLowerCase() == 'healthy';

  bool get isUncertain => confidence < 50.0;

  String get displayLabel {
    if (isUncertain) return 'Uncertain Result';
    // Format label for display (replace underscores with spaces)
    return label.replaceAll('_', ' ');
  }

  String get formattedConfidence => '${confidence.toStringAsFixed(1)}%';
}
