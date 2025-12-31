# Binance P2P Order Info 💰

[![Flutter CI](https://github.com/royalcourtbd/binance_order_info/actions/workflows/ci_validation.yml/badge.svg)](https://github.com/royalcourtbd/binance_order_info/actions/workflows/flutter_ci.yml)
[![Release CD](https://github.com/royalcourtbd/binance_order_info/actions/workflows/release_cd.yml/badge.svg)](https://github.com/royalcourtbd/binance_order_info/actions/workflows/release_cd.yml)
[![Security Scan](https://github.com/royalcourtbd/binance_order_info/actions/workflows/security_scan.yml/badge.svg)](https://github.com/royalcourtbd/binance_order_info/actions/workflows/security_scan.yml)
[![Manual Build](https://github.com/royalcourtbd/binance_order_info/actions/workflows/manual_build.yml/badge.svg)](https://github.com/royalcourtbd/binance_order_info/actions/workflows/manual_build.yml)
[![Latest Release](https://img.shields.io/github/v/release/royalcourtbd/binance_order_info)](https://github.com/royalcourtbd/binance_order_info/releases)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.38.5-blue)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.10.4-blue)](https://dart.dev/)

💰 Binance P2P Order Info - আপনার comprehensive companion for Binance P2P trading analysis! Flutter দিয়ে তৈরি করা এই app আপনার completed buy/sell orders track করে এবং detailed profit/loss analytics প্রদান করে।

## 📱 Download Latest Release

[⬇️ Download Latest APK from Releases](https://github.com/royalcourtbd/binance_order_info/releases)

> 🤖 **Automated Releases**: প্রতিটি version tag (`v1.0.0`, `v1.1.0`, etc.) automatically trigger করে আমাদের CI/CD pipeline যা secure APK & AAB files build করে split-per-abi optimization সহ।

### 📋 Installation Guide

1. **Download APK**: উপরের link click করে releases page এ যান
2. **Enable Unknown Sources**: Settings → Security → Enable "Unknown Sources"
3. **Install**: Downloaded APK open করে install করুন

## ✨ Key Features

- 📊 **Completed Orders Tracking**: গত 30 দিনের সব completed P2P orders দেখুন
- 💰 **Financial Summary**: Total buy/sell amounts, fees, এবং net profit calculation
- 📈 **Analytics Dashboard**: Average buy/sell prices, profit percentage
- 🔄 **Real-time Sync**: Backend API থেকে live data fetch
- 📅 **Date-wise Grouping**: Orders date অনুযায়ী organized
- 🔍 **Detailed Transaction View**: প্রতিটি transaction এর complete details
- ⚙️ **Configurable API**: Custom server IP configuration
- 🎨 **Modern Material Design 3**: Clean এবং intuitive UI
- 🚀 **Fast Performance**: Optimized data fetching with caching support

## 🚀 Development Setup

### 📋 Prerequisites

- Flutter SDK: 3.38.5 বা higher
- Dart SDK: 3.10.4 বা higher
- Android Studio বা VS Code with Flutter extension
- Git for version control
- Backend API server running (default: `http://192.168.0.101:8000`)

### 🛠️ Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/royalcourtbd/binance_order_info.git
   cd binance_order_info
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   ```bash
   flutter run
   ```

### 🔨 Build Commands

- **Debug APK**: `flutter build apk --debug`
- **Release APK (Single)**: `flutter build apk --release`
- **Release APK (Split per ABI)**: `flutter build apk --release --split-per-abi`
- **Release AAB**: `flutter build appbundle --release`

## 🔄 CI/CD & Automation Pipeline

আমাদের robust CI/CD pipeline নিশ্চিত করে code quality, security, এবং automated releases across multiple workflows:

### 🧪 Continuous Integration (CI) - `flutter_ci.yml`

**Triggers**: `build` branch এ push, Pull Requests to `main` বা `build`

**Pipeline Steps**:

- ✅ **Code Quality**: `flutter analyze` for static analysis
- 🧪 **Testing**: `flutter test` with optional coverage
- 🎯 **Format Check**: `dart format` validation
- 🔧 **Build Validation**: Debug APK build verification
- 📦 **Dependency Caching**: Optimized pub cache & Gradle cache

### 🚀 Continuous Deployment (CD) - `release_cd.yml`

**Triggers**: `build` branch এ push অথবা Version tags (`v*.*.*` pattern)

**Advanced Features**:

- 📱 **Split per ABI**: Smaller APK sizes (arm64-v8a, armeabi-v7a, x86_64)
- 📊 **Dynamic Changelogs**: Auto-generated from git commits
- 📦 **Multi-format**: Both APK and AAB generation
- 🌍 **Timezone Support**: Bangladesh time formatting
- 📁 **Artifact Management**: 30-day retention policy
- 🔖 **Rich Releases**: Detailed release notes with file sizes

**Release Assets**:

- 📱 `app-arm64-v8a-release.apk` - Modern 64-bit devices (Recommended)
- 📱 `app-armeabi-v7a-release.apk` - Older 32-bit devices
- 📱 `app-x86_64-release.apk` - Intel-based devices
- 📦 `app-release.aab` - Google Play Store bundle

### 🛡️ Security Scanning - `security_scan.yml`

**Triggers**:

- Push to `main` বা `build` branch
- Pull requests to `main` বা `build`
- Weekly scheduled scans (Monday 2 AM)

**Security Checks**:

- 🔍 **Dependency Auditing**: `dart pub audit` analysis
- 📋 **Outdated Packages**: Package update tracking
- 🔒 **Static Analysis**: Security-focused code analysis
- 🔐 **Sensitive Data Check**: Pattern detection for secrets

### ⚡ Manual Build Workflow - `manual_build.yml`

**On-Demand Features**:

- 🎛️ **Interactive Inputs**: Choose debug/release build type
- 📱 **Split APK Toggle**: Enable/disable split-per-abi
- ☑️ **Artifact Control**: Optional artifact upload
- 🔄 **Full Pipeline**: Analysis, testing, and building

### 🔧 Advanced CI/CD Features

- 🗂️ **Multi-level Caching**: Flutter SDK, Pub dependencies, Gradle
- 📋 **Code Quality Gates**: Mandatory analysis and formatting
- 🔒 **Security First**: Weekly vulnerability scans
- 🏷️ **Smart Tagging**: Semantic versioning support
- ⚡ **Performance Optimized**: Efficient build caching

## 📦 Release Management

### 🏷️ Semantic Versioning

আমরা follow করি [Semantic Versioning](https://semver.org/) principles:

- **MAJOR** (`v2.0.0`): Breaking changes
- **MINOR** (`v1.1.0`): New features (backward compatible)
- **PATCH** (`v1.0.1`): Bug fixes (backward compatible)

### 🚀 Release Process

1. **Update Version**

   ```bash
   # Update version in pubspec.yaml
   version: 1.1.0+2
   ```

2. **Commit Changes**

   ```bash
   git add .
   git commit -m "🚀 Release v1.1.0: Add new features"
   git push origin main
   ```

3. **Create & Push Tag**

   ```bash
   git tag -a v1.1.0 -m "Release v1.1.0"
   git push origin v1.1.0
   ```

4. **Automated Pipeline 🤖**

   - ✅ Triggers release workflow
   - ✅ Builds APK & AAB with split-per-abi
   - ✅ Creates GitHub release with changelogs
   - ✅ Uploads artifacts automatically

## 🏗️ Architecture & Tech Stack

### 🛠️ Core Technologies

**Framework & Language**:

- Flutter SDK: 3.38.5
- Dart SDK: 3.10.4
- Material Design 3: Modern UI components

**State Management & Dependencies**:

- **GetX** (`get: ^4.6.6`): State management & routing
- **HTTP** (`http: ^1.1.0`): API communication
- **Shared Preferences** (`shared_preferences: ^2.2.2`): Local data persistence
- **Intl** (`intl: ^0.19.0`): Date/number formatting

**Development Tools**:

- Flutter Lints: Code quality enforcement
- Dart Format: Consistent code formatting

### 📦 Project Structure

```
lib/
├── app.dart                    # Main app configuration
├── main.dart                   # Entry point
├── config/
│   └── api_config.dart        # API endpoints & configuration
├── controllers/
│   └── orders_controller.dart # State management
├── models/
│   ├── api_response_model.dart
│   ├── transaction_item_model.dart
│   ├── date_section_model.dart
│   └── summary_item_model.dart
├── screens/
│   ├── p2p_order_screen.dart  # Main screen
│   └── transaction_details_screen.dart
├── services/
│   └── orders_api_service.dart # API service layer
└── widgets/
    ├── date_section.dart
    ├── transaction_item.dart
    ├── summary_item.dart
    └── [other widgets...]
```

---

**Note**: এই app শুধু Binance P2P orders track করার জন্য। Trading বা order placement এর জন্য নয়।
