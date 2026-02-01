<div align="center">

# 🍅 Tomato Leaf Disease Detector

**AI-Powered Plant Disease Detection using TensorFlow Lite and Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![TensorFlow Lite](https://img.shields.io/badge/TensorFlow%20Lite-Latest-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<br/>

</div>

---

## 📱 Screenshots

<p align="center">
  <img src="screenshots/welcome-dark.png" width="250" alt="welcome dark"/>
  <img src="screenshots/scanner-dark.png" width="250" alt="Home Dashboard"/>
  <img src="screenshots/welcome-light.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/scanner-light.png" width="250" alt="Feed Cost Calculator"/>
</p>
<p align="center">
  <img src="screenshots/scanner2-dark.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/scanner3-dark.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/scanner2-light.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/scanner3-light.png" width="250" alt="Feed Cost Calculator"/>
</p>
<p align="center">
  <img src="screenshots/scanner4-dark.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/result-dark.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/scanner4-light.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/result-light.png" width="250" alt="Feed Cost Calculator"/>
</p>
<p align="center">
  <img src="screenshots/result1-dark.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/result1-light.png" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/tiktok.png" width="250" alt="Feed Cost Calculator"/>
</p>


## Overview

Tomato Leaf Disease Detector is a mobile application that uses machine learning to identify diseases in tomato plants. The app leverages TensorFlow Lite models to analyze plant leaf images and provide instant disease detection with high accuracy.

**Two-Stage Verification System:**

1. **Stage 1 - Verification Model** - Confirms if the image contains a tomato leaf
2. **Stage 2 - Disease Detection Model** - Identifies specific diseases if verified as a tomato leaf

---

## Features

### AI-Powered Disease Detection

- Two-Stage Verification - First verifies tomato leaf presence, then detects diseases
- Real-time Analysis - Instant disease detection from camera or gallery images
- High Accuracy - Powered by optimized TensorFlow Lite models
- Confidence Scores - Display confidence percentages for predictions

### Image Input Options

- Camera Capture - Take photos directly from your device camera
- Gallery Selection - Choose images from your device storage
- Image Preprocessing - Automatic image optimization and resizing

### Modern User Interface

- Material Design 3 - Clean, intuitive, and professional interface
- Dark & Light Themes - Toggle between themes with persistent preferences
- Smooth Animations - Professional animations and transitions
- Professional Splash Screen - Elegant loading experience with animated visuals

### Performance Optimized

- Background Model Loading - Models load in background isolates without blocking UI
- Parallel Processing - Both models initialize simultaneously
- Efficient Preprocessing - Image preprocessing in isolated threads
- Minimal Memory Footprint - Optimized for mobile devices

### Data Persistence

- Theme Preferences - Save user's theme selection locally
- Session Management - Persistent app state across sessions

---

## Tech Stack

| Technology             | Purpose                              |
| ---------------------- | ------------------------------------ |
| Flutter 3.10.7         | Cross-platform mobile UI framework   |
| Dart 3.0+              | Programming language                 |
| TensorFlow Lite 0.12.1 | On-device machine learning inference |
| Image Picker           | Camera and gallery image selection   |
| File Picker            | File system access                   |
| Shared Preferences     | Local data persistence               |
| Google Fonts           | Typography                           |
| Font Awesome Flutter   | Iconography                          |
| Image Processing       | Image manipulation and preprocessing |

---

## Architecture

### Model Loading Strategy

- Global Singleton Pattern - `GlobalModelManager` manages all models globally
- Isolate-Based Loading - Models initialize in background isolates for non-blocking UI
- Parallel Initialization - Both verification and disease detection models load simultaneously
- Main Thread Binding - Asset loading happens in main thread, interpretation in isolates

### Service Layer

- MLService - High-level prediction interface with two-stage verification
- ModelIsolateService - Low-level isolate management and model initialization
- ImageHelper - Image preprocessing and normalization

### Data Flow

```
User selects image
    ↓
ImageHelper preprocesses (in isolate)
    ↓
Stage 1: Verification Model runs
    ↓
If tomato leaf: Stage 2: Disease detection runs
    ↓
PredictionResult returned with confidence and status
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── global_model_manager.dart      # Global ML model lifecycle management
│   └── theme_notifier.dart            # Theme state management
├── models/
│   ├── prediction_result.dart         # Prediction data model
│   └── preprocess_params.dart         # Image preprocessing parameters
├── screens/
│   ├── splash_screen.dart             # Animated splash with model loading
│   ├── welcome_screen.dart            # Main welcome/home screen
│   ├── camera_screen.dart             # Camera capture interface
│   └── result_screen.dart             # Disease detection results display
├── services/
│   ├── ml_service.dart                # Two-stage prediction service
│   ├── model_isolate_service.dart     # Isolate-based model initialization
│   └── image_helper.dart              # Image preprocessing utilities
└── widgets/
    ├── loading_spinner.dart           # Reusable loading indicator
    └── custom_widgets.dart            # Shared UI components
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Dart 3.0 or higher
- Android SDK (for Android) or Xcode (for iOS)

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd flutter_tomato_leaf_disease_detector
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Android (if building for Android)**

```bash
cd android
./gradlew clean
cd ..
```

4. **Run the app**

```bash
flutter run
```

For release builds:

```bash
flutter run --release
```

---

## Machine Learning Models

### Models Included

- tomato_or_not_model.tflite - Verification model (224x224 input)
  - Verifies if image contains a tomato leaf
  - Labels: "Tomato Leaf", "Not Tomato Leaf"

- tomato_leaf_disease_model.tflite - Disease detection model (224x224 input)
  - Identifies specific diseases in tomato leaves
  - Supports multiple disease classes

### Model Location

```
assets/models/
├── tomato_or_not_model.tflite
├── tomato_or_not_model_labels.txt
├── tomato_leaf_disease_model.tflite
└── tomato_leaf_disease_model_labels.txt
```

---

## Model Loading Flow

1. App Startup → Splash screen initiates model loading
2. Parallel Loading → Both models load simultaneously in background isolates
3. Main Thread Binding → Assets loaded in main thread (requires Flutter binding)
4. Isolate Processing → Model bytes passed to isolates for interpreter creation
5. Ready State → Models cached globally and reused for all predictions
6. Navigation → After 5-second minimum display, app navigates to welcome screen

---

## Usage

1. **Launch App** - App loads with animated splash screen
2. **Select Image** - Tap camera icon to capture or select from gallery
3. **Analysis** - App performs two-stage verification and disease detection
4. **Results** - View disease name, confidence, and disease-specific information
5. **Save** - Option to save results locally

---

## Privacy & Security

- **On-Device Processing** - All inference happens locally, no data sent to servers
- **No Permissions Needed** - Only requires camera/storage access for selected images
- **No Data Collection** - User images are not stored or transmitted

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

Developed using Flutter and TensorFlow Lite

---

## Acknowledgments

- TensorFlow Lite for efficient on-device machine learning
- Flutter community for excellent documentation and tools
- Plant disease research community for model training datasets

---

## Support

For questions, issues, or suggestions, please open an issue on the repository.

**Happy Farming!**

### ⭐ Star this repository if you find it helpful!

Made with ❤️ and Flutter

</div>
