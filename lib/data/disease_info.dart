import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Disease information database with causes and solutions
enum DiseaseType {
  virus(
    'Viral Infection',
    Colors.orange,
    'assets/icon/diseases/coronavirus.png',
    FontAwesomeIcons.virus,
  ),
  bacteria(
    'Bacterial Infection',
    Colors.purpleAccent,
    'assets/icon/diseases/bacteria (1).png',
    FontAwesomeIcons.bacterium,
  ),
  fungus(
    'Fungal Infection',
    Colors.lightGreen,
    'assets/icon/diseases/allergies.png',
    FontAwesomeIcons.spaghettiMonsterFlying,
  ),
  pest(
    'Pest Infestation',
    Colors.redAccent,
    'assets/icon/diseases/pest.png',
    FontAwesomeIcons.spider,
  ),
  healthy(
    'Healthy',
    Colors.green,
    'assets/icon/leaf-healthy.png',
    FontAwesomeIcons.leaf,
  ),
  invalid(
    'Invalid Input',
    Colors.blueGrey,
    'assets/icon/research.png',
    FontAwesomeIcons.triangleExclamation,
  ),
  other(
    'Unknown',
    Colors.grey,
    'assets/icon/question (1).png',
    FontAwesomeIcons.circleQuestion,
  );

  final String typeName;
  final Color typeColor;
  final String iconPath;
  final IconData typeIcon;

  const DiseaseType(
    this.typeName,
    this.typeColor,
    this.iconPath,
    this.typeIcon,
  );
}

class DiseaseInfo {
  final String name;
  final String description;
  final List<String> causes;
  final List<String> solutions;
  final Color backgroundColor;
  final bool isHealthy;
  final bool isOther;
  final bool isInvalid;
  final DiseaseType type;

  const DiseaseInfo({
    required this.name,
    required this.description,
    required this.causes,
    required this.solutions,
    required this.type,
    this.backgroundColor = AppColors.cardLight,
    this.isHealthy = false,
    this.isOther = false,
    this.isInvalid = false,
  });

  static DiseaseInfo? getInfo(String label) {
    final normalizedLabel = label.toLowerCase().replaceAll(' ', '_');
    return _diseaseDatabase[normalizedLabel];
  }

  static List<DiseaseInfo> get allDiseases => _diseaseDatabase.values.toList();

  static const Map<String, DiseaseInfo> _diseaseDatabase = {
    'healthy': DiseaseInfo(
      name: 'Healthy Plant',
      type: DiseaseType.healthy,
      description:
          'Your plant appears to be vibrant and healthy, exhibiting strong growth and no visible signs of stress, pests, or disease. The leaves are a rich green color, free from spots or yellowing, and the stems are sturdy. Maintaining this state requires consistent care and monitoring.',
      causes: [
        'Optimal watering schedule',
        'Balanced nutrient availability',
        'Good soil drainage and aeration',
        'Adequate sunlight exposure',
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
      type: DiseaseType.bacteria,
      description:
          'Bacterial Spot is a serious disease that affects tomatoes and peppers. It manifests as small, dark, water-soaked spots on leaves, stems, and fruits. As the disease progresses, these spots can enlarge and merge, leading to extensive leaf yellowing and premature leaf drop, which exposes fruits to sunscald.',
      causes: [
        'Xanthomonas bacteria spread through infected seeds',
        'Warm, humid weather conditions (75-86°F)',
        'Overhead irrigation spreading bacteria via splashing',
        'Contaminated garden tools or working in wet plants',
      ],
      solutions: [
        'Remove and destroy infected plant parts',
        'Apply copper-based bactericides early',
        'Use disease-free certified seeds',
        'Avoid overhead watering',
        'Practice crop rotation for 2-3 years',
      ],
    ),
    'early_blight': DiseaseInfo(
      name: 'Early Blight',
      type: DiseaseType.fungus,
      description:
          'Early Blight is a common fungal disease that typically starts on the lower, older leaves. It is characterized by irregular dark spots with concentric rings, giving them a "target-like" appearance. The tissue around spots often turns yellow. Left unchecked, it can defoliate the plant and reduce yield significanty.',
      causes: [
        'Alternaria solani fungus persisting in soil debris',
        'Warm temperatures (75-85°F) with high humidity',
        'Alternating wet and dry conditions',
        'Poor air circulation and crowded planting',
      ],
      solutions: [
        'Remove infected leaves promptly (bottom-up)',
        'Apply fungicides containing chlorothalonil or copper',
        'Mulch around plants to prevent soil splash',
        'Improve air circulation between plants',
        'Water at the base of plants, not foliage',
      ],
    ),
    'late_blight': DiseaseInfo(
      name: 'Late Blight',
      type: DiseaseType.fungus,
      description:
          'Late Blight is a destructive disease capable of killing plants rapidly. It causes large, irregular grey-green spots that turn brown and papery. In humid weather, a white fungal growth may appear on the undersides of leaves. It affects all above-ground parts and can rot harvestable fruit.',
      causes: [
        'Phytophthora infestans water mold pathogen',
        'Cool, wet weather conditions',
        'Infected transplants or volunteer potatoes',
        'Airborne spores from nearby infected fields',
      ],
      solutions: [
        'Remove and destroy infected plants immediately',
        'Apply fungicides preventively in wet weather',
        'Plant resistant varieties',
        'Ensure good drainage in growing area',
        'Avoid planting near potatoes',
      ],
    ),
    'leaf_mold': DiseaseInfo(
      name: 'Leaf Mold',
      type: DiseaseType.fungus,
      description:
          'Leaf Mold primarily affects foliage, appearing first as pale green or yellow spots on the upper leaf surface. Simultaneously, an olive-green to gray velvety mold develops on the undersides directly beneath these spots. Is is most common in high-humidity environments like greenhouses.',
      causes: [
        'Passalora fulva fungus',
        'High humidity (above 85%) for prolonged periods',
        'Poor ventilation in greenhouses or dense canopies',
        'Mild temperatures between 71-75°F',
      ],
      solutions: [
        'Improve greenhouse ventilation and airflow',
        'Reduce humidity to below 85%',
        'Space plants for better airflow',
        'Apply appropriate fungicides',
        'Remove infected leaves carefully',
      ],
    ),
    'septoria_leaf_spot': DiseaseInfo(
      name: 'Septoria Leaf Spot',
      type: DiseaseType.fungus,
      description:
          'Septoria Leaf Spot is one of the most destructive diseases of tomato foliage. It appears as numerous small, circular spots with dark borders and light gray centers. Small black specks (fruiting bodies) may be visible in the center. It usually starts on lower leaves and moves upward.',
      causes: [
        'Septoria lycopersici fungus',
        'Warm, wet conditions and splashing water',
        'Infected plant debris left in soil',
        'High humidity and rainfall',
      ],
      solutions: [
        'Remove lower leaves showing symptoms',
        'Apply copper-based or chlorothalonil fungicides',
        'Mulch to prevent soil splash',
        'Practice 3-year crop rotation',
        'Stake plants for better air circulation',
      ],
    ),
    'spider_mites two-spotted_spider_mite': DiseaseInfo(
      name: 'Spider Mites',
      type: DiseaseType.pest,
      description:
          'Spider Mites are tiny sap-sucking arachnids that cause leaves to look stippled, yellowed, or bronzed. Large populations produce visible fine webbing covering leaves. They thrive in hot, dry conditions and can weaken plants rapidly by removing chlorophyll.',
      causes: [
        'Tetranychus urticae infestation',
        'Hot, dry, and dusty conditions',
        'Water stress in plants',
        'Overuse of broad-spectrum insecticides killing predators',
      ],
      solutions: [
        'Spray plants with strong water jet to dislodge',
        'Apply insecticidal soap or neem oil',
        'Introduce predatory mites',
        'Increase humidity around plants (misting)',
        'Remove severely infested leaves',
      ],
    ),
    'target_spot': DiseaseInfo(
      name: 'Target Spot',
      type: DiseaseType.fungus,
      description:
          'Target Spot affects leaves, stems, and fruit. On leaves, it causes brown-black lesions with subtle concentric rings (targets). These lesions can merge, causing large dead areas. It is favored by warm temperatures and high humidity.',
      causes: [
        'Corynespora cassiicola fungus',
        'Warm, humid conditions',
        'Extended periods of leaf wetness',
        'Dense plant canopy reducing airflow',
      ],
      solutions: [
        'Prune lower leaves to increase airflow',
        'Apply fungicides early in the season',
        'Reduce overhead irrigation',
        'Remove infected plant material',
        'Use resistant varieties when available',
      ],
    ),
    'tomato_yellow_leaf_curl_virus': DiseaseInfo(
      name: 'Tomato Yellow Leaf Curl Virus',
      type: DiseaseType.virus,
      description:
          'TYLCV is a severe viral disease that stunts plant growth. Leaves become reduced in size, curl upward, crinkle, and turn yellow at the edges. Infected plants often drop their flowers and stop producing fruit, leading to significant yield loss.',
      causes: [
        'Transmitted primarily by Silverleaf Whiteflies',
        'Infected transplants introduced to the garden',
        'Nearby infected weeds or crops',
        'Warm climates favorable for whitefly reproduction',
      ],
      solutions: [
        'Remove and destroy infected plants immediately',
        'Control whitefly populations with traps/sprays',
        'Use reflective mulches to deter whiteflies',
        'Plant resistant varieties',
        'Use insect-proof netting on seedlings',
      ],
    ),
    'tomato_mosaic_virus': DiseaseInfo(
      name: 'Tomato Mosaic Virus',
      type: DiseaseType.virus,
      description:
          'Tomato Mosaic Virus (ToMV) causes a light and dark green mottled or mosaic pattern on leaves. Leaves may also be fern-like or distorted. The fruit may show internal browning. It is highly contagious and mechanically transmitted.',
      causes: [
        'Mechanically transmitted via tools and hands',
        'Infected seeds or transplants',
        'Contaminated soil or plant debris',
        'Smokers handling plants (closely related to TMV)',
      ],
      solutions: [
        'Remove and destroy infected plants',
        'Wash hands thoroughly before handling plants',
        'Disinfect tools with 10% bleach solution',
        'Use certified virus-free seeds',
        'Avoid smoking near plants',
      ],
    ),
    'unknown_disease': DiseaseInfo(
      name: 'Unknown or Unrecognized Condition',
      type: DiseaseType.other,
      isOther: true,
      description:
          'The model was unable to confidently identify a specific disease or condition in the provided image. This may indicate a rare disease, a combination of conditions, environmental stress not directly caused by pathogens, or a crop that is not a tomato leaf. For accurate diagnosis, we recommend consulting with a local agricultural extension service or plant pathologist.',
      causes: [
        'Rare or undocumented disease',
        'Multiple simultaneous conditions',
        'Environmental stress (nutrient deficiency, water stress, temperature extremes)',
        'Image quality or lighting issues affecting analysis',
      ],
      solutions: [
        'Take a clearer, well-lit photo of the affected area',
        'Try scanning the same leaf from different angles',
        'Consult with a local agricultural expert',
        'Monitor the plant for disease progression',
        'Ensure proper watering, nutrition, and environmental conditions',
      ],
    ),
    'not_a_tomato_leaf': DiseaseInfo(
      name: 'Not a Tomato Leaf',
      type: DiseaseType.invalid,
      isInvalid: true,
      description:
          'The verification model has determined that the provided image does not contain a tomato leaf. This application is specifically designed to detect diseases in tomato plants only. Please capture an image of an actual tomato leaf and try again. Ensure the leaf is clearly visible and well-lit.',
      causes: [
        'Image does not show a tomato leaf',
        'Image shows a different plant species',
        'Image is blurry or poorly lit',
        'Image shows only soil, fruit, or other non-leaf parts',
      ],
      solutions: [
        'Take a clear photo of a tomato leaf',
        'Ensure adequate lighting when capturing the image',
        'Keep the leaf in focus and fill most of the frame',
        'Avoid shadows or extreme lighting conditions',
        'Try capturing from different angles if the first attempt fails',
      ],
    ),
  };
}
