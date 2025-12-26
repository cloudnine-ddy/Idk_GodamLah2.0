# JagaID

> Malaysia Digital Identity Access - A Flutter application for secure digital identity management with accessibility features for elderly users, guardian support, and field agent capabilities.

[![Flutter](https://img.shields.io/badge/Flutter-3.10.1-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.10.1-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Key Features Explained](#key-features-explained)
- [Technologies Used](#technologies-used)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

JagaID is a comprehensive digital identity access application designed for the Malaysian government initiative. The app provides secure access to digital identity services with special focus on accessibility for elderly users, guardian management capabilities, and field agent functionality for government workers.

The application supports multiple user profiles with different accessibility needs, NFC card scanning, QR code binding, and integration with MyDigital ID authentication system.

## ✨ Features

### Core Functionality
- **🔐 Secure Identity Access**: Tap-to-access NFC card scanning for quick authentication
- **👴 Elderly-Friendly Interface**: Specialized screens with accessibility features
- **👨‍👩‍👧 Guardian Management**: Family members can manage and authorize actions for elderly users
- **👮 Field Agent Mode**: Government workers can access villager profiles and manage transactions
- **📱 MyDigital ID Integration**: Seamless login with Malaysia's official digital identity system

### Accessibility Features
- **🌐 Multi-language Support**: English, Chinese (Simplified), and Malay
- **🔍 Big Text Mode**: Enhanced readability for visually impaired users
- **🎨 High Contrast Mode**: Improved visibility for users with visual difficulties
- **🔔 Proactive Notifications**: Important alerts for document expiration and aid status

### Technical Features
- **📲 NFC Card Scanning**: Tap JagaID card on device for instant access
- **📷 QR Code Binding**: Link devices using QR codes for guardian-senior relationships
- **🎭 Multiple User Profiles**: Switch between different user profiles for testing and demos
- **💳 Digital Wallet Integration**: View bank accounts and government aid status
- **📊 Transaction Management**: Track field transactions and villager data

## 📸 Screenshots

> _Screenshots will be added here_

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.10.1 or higher)
- **Dart SDK** (3.10.1 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **Git** for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/jagaid.git
   cd jagaid/app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

4. **Build for production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point and landing page
├── models/                   # Data models
│   ├── dependent.dart        # Dependent model
│   ├── field_transaction.dart # Field transaction model
│   ├── user_profile.dart     # User profile with accessibility settings
│   └── villager.dart         # Villager model for field agents
├── screens/                  # UI screens
│   ├── binding_screen.dart   # NFC/QR code binding interface
│   ├── dashboard_screen.dart # Main dashboard
│   ├── elderly_screen.dart   # Elderly user interface
│   ├── guardian_screen.dart  # Guardian management interface
│   ├── success_screen.dart   # Success confirmation screens
│   └── field_agent/         # Field agent specific screens
│       ├── field_agent_dashboard.dart
│       └── villager_profile_screen.dart
├── services/                 # Business logic and services
│   ├── binding_service.dart  # NFC/QR binding logic
│   └── field_agent_service.dart # Field agent operations
└── utils/                    # Utility classes
    └── app_globals.dart      # Global application state
```

## 💡 Usage

### For Elderly Users

1. Launch the app and tap the top half of the screen or use "Log in with MyDigital ID"
2. Select your profile (supports multiple accessibility modes)
3. Access your digital identity, view aid status, and manage documents
4. Use voice assistance and accessibility features as needed

### For Guardians

1. Launch the app and tap the bottom half of the screen
2. Select the elderly person you're managing
3. Authorize transactions, view status, and manage dependent accounts
4. Use QR code or NFC binding to link devices

### For Field Agents

1. Click "Field Agent Mode" button on the landing page
2. Access villager profiles and manage field transactions
3. View and update villager information
4. Process government aid applications

### Profile Switching (Demo Mode)

Use the profile switcher icon (top-right) to switch between demo profiles:
- **Uncle Tan**: Default English profile
- **Grandma Lin**: Chinese language with big text
- **Uncle Muthu**: High contrast mode
- **Ali**: Guardian profile (Son)

## 🔑 Key Features Explained

### NFC Card Scanning
Tap your JagaID card on the back of the device to instantly authenticate and access services. The app uses NFC technology for secure, contactless authentication.

### QR Code Binding
Link guardian and senior devices using QR codes. The system generates time-limited QR codes (5 minutes) for secure pairing.

### Accessibility Modes
- **Big Text Mode**: Increases font sizes throughout the app for better readability
- **High Contrast Mode**: Uses high-contrast color schemes for improved visibility
- **Multi-language**: Full interface translation in English, Chinese, and Malay

### MyDigital ID Integration
Seamless integration with Malaysia's official digital identity system for secure authentication and identity verification.

## 🛠 Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **Google Fonts**: Typography (Poppins font family)
- **Material Design 3**: Modern UI components
- **NFC**: Near Field Communication for card scanning
- **QR Code**: For device binding

### Dependencies

- `flutter`: SDK
- `google_fonts: ^6.2.1`: Custom typography
- `cupertino_icons: ^1.0.8`: iOS-style icons

## 🔧 Development

### Running in Debug Mode
```bash
flutter run
```

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Building for Different Platforms
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure all tests pass before submitting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This is a **mock pilot** application for demonstration purposes. It is part of an official government initiative prototype and should not be used for production purposes without proper security audits and government approval.

## 📞 Support

For issues, questions, or contributions, please open an issue on the GitHub repository.

---

**Note**: This application is part of the Malaysia Digital Identity initiative and is currently in pilot/demo phase.
