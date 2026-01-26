import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_colors.dart';

/// Disease information database with causes and solutions
class DiseaseInfo {
  final String name;
  final String description;
  final List<String> causes;
  final List<String> solutions;
  final Color backgroundColor;
  final bool isHealthy;

  const DiseaseInfo({
    required this.name,
    required this.description,
    required this.causes,
    required this.solutions,
    this.backgroundColor = AppColors.cardLight,
    this.isHealthy = false,
  });

  static DiseaseInfo? getInfo(String label) {
    final normalizedLabel = label.toLowerCase().replaceAll(' ', '_');
    return _diseaseDatabase[normalizedLabel];
  }

  static List<DiseaseInfo> get allDiseases => _diseaseDatabase.values.toList();

  static const Map<String, DiseaseInfo> _diseaseDatabase = {
    'healthy': DiseaseInfo(
      name: 'Healthy Plant',
      description:
          'Your plant appears to be healthy with no visible signs of disease.',
      causes: [
        'Great news! No disease detected.',
      ],
      solutions: [
        'Continue regular watering schedule',
        'Maintain proper nutrition with balanced fertilizer',
        'Monitor regularly for early signs of problems',
        'Ensure adequate sunlight exposure',
        'Keep garden clean and weed-free',
      ],
      isHealthy: true,
    ),
    'bacterial_spot': DiseaseInfo(
      name: 'Bacterial Spot',
      description:
          'A bacterial infection causing dark, water-soaked spots on leaves and fruit.',
      causes: [
        'Xanthomonas bacteria spread through infected seeds',
        'Warm, humid weather conditions',
        'Overhead irrigation spreading bacteria',
        'Contaminated garden tools',
      ],
      solutions: [
        'Remove and destroy infected plant parts',
        'Apply copper-based bactericides',
        'Use disease-free certified seeds',
        'Avoid overhead watering',
        'Practice crop rotation for 2-3 years',
      ],
    ),
    'early_blight': DiseaseInfo(
      name: 'Early Blight',
      description:
          'A fungal disease causing dark spots with concentric rings on lower leaves.',
      causes: [
        'Alternaria solani fungus',
        'Warm temperatures (75-85°F)',
        'High humidity and wet foliage',
        'Poor air circulation',
        'Over-watering or splashing water',
      ],
      solutions: [
        'Remove infected leaves promptly',
        'Apply fungicides containing chlorothalonil',
        'Mulch around plants to prevent soil splash',
        'Improve air circulation between plants',
        'Water at the base of plants, not foliage',
      ],
    ),
    'late_blight': DiseaseInfo(
      name: 'Late Blight',
      description:
          'A devastating fungal-like disease causing rapid plant death.',
      causes: [
        'Phytophthora infestans pathogen',
        'Cool, wet weather conditions',
        'Infected transplants or tubers',
        'Airborne spores from nearby fields',
      ],
      solutions: [
        'Remove and destroy infected plants immediately',
        'Apply fungicides preventively',
        'Plant resistant varieties',
        'Ensure good drainage in growing area',
        'Avoid planting near potatoes',
      ],
    ),
    'leaf_mold': DiseaseInfo(
      name: 'Leaf Mold',
      description:
          'A fungal infection causing yellow spots on upper leaves and olive-green mold underneath.',
      causes: [
        'Passalora fulva fungus',
        'High humidity (above 85%)',
        'Poor ventilation in greenhouses',
        'Temperatures between 71-75°F',
      ],
      solutions: [
        'Improve greenhouse ventilation',
        'Reduce humidity to below 85%',
        'Space plants for better airflow',
        'Apply appropriate fungicides',
        'Remove infected leaves',
      ],
    ),
    'septoria_leaf_spot': DiseaseInfo(
      name: 'Septoria Leaf Spot',
      description:
          'A fungal disease causing small, circular spots with dark borders on leaves.',
      causes: [
        'Septoria lycopersici fungus',
        'Warm, wet conditions',
        'Splashing water from rain or irrigation',
        'Infected plant debris in soil',
      ],
      solutions: [
        'Remove lower leaves showing symptoms',
        'Apply copper-based fungicides',
        'Mulch to prevent soil splash',
        'Practice 3-year crop rotation',
        'Stake plants for better air circulation',
      ],
    ),
    'spider_mites two-spotted_spider_mite': DiseaseInfo(
      name: 'Spider Mites',
      description:
          'Tiny pests causing stippled, yellowing leaves with fine webbing.',
      causes: [
        'Tetranychus urticae infestation',
        'Hot, dry conditions',
        'Dusty environments',
        'Overuse of broad-spectrum insecticides killing natural predators',
      ],
      solutions: [
        'Spray plants with strong water jet',
        'Apply insecticidal soap or neem oil',
        'Introduce predatory mites',
        'Increase humidity around plants',
        'Avoid pesticides that harm beneficial insects',
      ],
    ),
    'target_spot': DiseaseInfo(
      name: 'Target Spot',
      description:
          'A fungal disease causing brown spots with concentric rings resembling targets.',
      causes: [
        'Corynespora cassiicola fungus',
        'Warm, humid conditions',
        'Extended leaf wetness',
        'Dense plant canopy',
      ],
      solutions: [
        'Prune lower leaves for airflow',
        'Apply fungicides early in season',
        'Reduce overhead irrigation',
        'Remove infected plant material',
        'Use resistant varieties when available',
      ],
    ),
    'tomato_yellow_leaf_curl_virus': DiseaseInfo(
      name: 'Tomato Yellow Leaf Curl Virus',
      description:
          'A viral disease causing severe leaf curling, yellowing, and stunted growth.',
      causes: [
        'Transmitted by whiteflies (Bemisia tabaci)',
        'Infected transplants',
        'Nearby infected plants',
        'Warm climates favorable for whiteflies',
      ],
      solutions: [
        'Remove and destroy infected plants',
        'Control whitefly populations',
        'Use reflective mulches to deter whiteflies',
        'Plant resistant varieties',
        'Use insect-proof netting on seedlings',
      ],
    ),
    'tomato_mosaic_virus': DiseaseInfo(
      name: 'Tomato Mosaic Virus',
      description:
          'A viral disease causing mottled light and dark green patterns on leaves.',
      causes: [
        'Highly stable virus spread by contact',
        'Infected seeds or transplants',
        'Contaminated hands or tools',
        'Smoking tobacco near plants (tobacco mosaic)',
      ],
      solutions: [
        'Remove and destroy infected plants',
        'Wash hands before handling plants',
        'Disinfect tools with 10% bleach solution',
        'Use certified virus-free seeds',
        'Avoid smoking near plants',
      ],
    ),
  };
}
