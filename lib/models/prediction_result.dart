/// Enum for verification status during multi-stage prediction
enum VerificationStatus { notTomatoLeaf, isTomatoLeaf, inconclusive }

/// Represents the result of a disease prediction
class PredictionResult {
  final String label;
  final double confidence;
  final bool isHealthy;
  final VerificationStatus verificationStatus;
  final double? verificationConfidence;

  PredictionResult({
    required this.label,
    required this.confidence,
    this.verificationStatus = VerificationStatus.isTomatoLeaf,
    this.verificationConfidence,
  }) : isHealthy = label.toLowerCase() == 'healthy';

  bool get isUncertain => confidence < 81.0;

  bool get isValidTomatoLeaf =>
      verificationStatus == VerificationStatus.isTomatoLeaf;

  bool get requiresVerification =>
      verificationConfidence != null && verificationConfidence! < 75.0;

  String get displayLabel {
    if (!isValidTomatoLeaf) return 'Not a Tomato Leaf';
    if (isUncertain) return 'Uncertain Result';
    // Format label for display (replace underscores with spaces)
    return label.replaceAll('_', ' ');
  }

  String get formattedConfidence => '${confidence.toStringAsFixed(1)}%';
}
