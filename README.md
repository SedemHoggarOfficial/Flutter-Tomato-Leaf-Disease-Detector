<div align="center">

#Leaf Guard - Flutter Poultry Calculator

**Your Digital Companion for Intelligent Poultry Farming Calculations**

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<br/>

<!-- <video width="400" controls>
  <source src="screenshots/video.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video> -->

</div>

---

## 📱 Screenshots

<p align="center">
  <img src="screenshots/IMG6.PNG" width="250" alt="Welcome Screen"/>
  <img src="screenshots/IMG7.PNG" width="250" alt="Home Dashboard"/>
  <img src="screenshots/IMG5.PNG" width="250" alt="Feed Cost Calculator"/>
</p>
<p align="center">
  <img src="screenshots/IMG1.PNG" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/IMG2.PNG" width="250" alt="Feed Cost Calculator"/>
  <img src="screenshots/IMG4.PNG" width="250" alt="Feed Cost Calculator"/>
</p>
<p align="center">
  <img src="screenshots/IMG3.PNG" width="250" alt="Feed Cost Calculator"/>
</p>

---

## ✨ Features

PoultryPal is a comprehensive poultry farm management calculator that helps farmers make data-driven decisions. The app includes:

### 🧮 Feed Cost Calculator
- Calculate total feed costs based on flock size, duration, and feed types
- Support for multiple poultry types (Broilers, Layers, etc.)
- Customizable feed pricing with Ghana Cedi (GH₵) currency support
- Period-based calculations with detailed breakdowns

### 💧 Water Requirements Calculator
- Calculate daily water needs based on bird count and age
- Temperature-adjusted recommendations
- Daily and period-based consumption estimates

### 🌾 Feed Requirements Calculator
- Determine daily feed needs in grams or kilograms
- Age-appropriate feeding schedules
- Support for different poultry breeds and growth stages

### 🏠 Housing Requirements Calculator
- Calculate optimal space requirements for your flock
- Equipment recommendations (feeders, drinkers, etc.)
- Ventilation and lighting guidelines

### 💊 Drug Dosage Calculator
- Calculate accurate medication dosages for your flock
- Support for various medication types and concentrations
- Weight-based and water-based dosing options

---

## 🎨 Design Highlights

- **Modern Material Design 3** - Clean and intuitive user interface
- **Dark & Light Themes** - Toggle between themes with persistent preferences
- **Smooth Animations** - Delightful micro-interactions and transitions
- **Responsive Layout** - Optimized for various screen sizes
- **Premium Aesthetics** - Gradient backgrounds, glassmorphism effects, and polished UI components

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.10+** | Cross-platform UI framework |
| **Dart 3.0+** | Programming language |
| **Riverpod** | State management |
| **Shared Preferences** | Local data persistence |
| **Google Fonts** | Typography (Inter, Roboto) |
| **Font Awesome** | Iconography |
| **Device Preview** | Cross-device testing |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/SedemHoggarOfficial/Flutter-Poultry-Calculator.git
   cd Flutter-Poultry-Calculator
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 📁 Project Structure

```
lib/
├── core/
│   └── theme/           # App theming (colors, typography, theme providers)
├── data/
│   ├── jsons/           # JSON data files
│   └── schedules/       # Feed schedules and period data
├── models/              # Data models
├── screens/             # UI screens
│   ├── home_page.dart
│   ├── welcome_screen.dart
│   ├── feed_cost_calculator.dart
│   ├── feed_requirement_calculator.dart
│   ├── water_requirement_calculator.dart
│   ├── housing_requirements_screen.dart
│   └── drug_dosage_calculator.dart
├── services/            # Business logic services
├── widgets/             # Reusable UI components
└── main.dart            # App entry point
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Sedem Hoggar**

- GitHub: [@SedemHoggarOfficial](https://github.com/SedemHoggarOfficial)

---

<div align="center">

### ⭐ Star this repository if you find it helpful!

Made with ❤️ and Flutter

</div>