# 📱 Binance P2P Order Info

একটি Flutter-based Android অ্যাপ্লিকেশন যা Binance P2P trading orders track করে এবং detailed analytics প্রদান করে। এই app আপনার completed buy/sell orders দেখাবে এবং profit/loss calculation সহ comprehensive summary প্রদান করবে।

[![Flutter CI](https://github.com/YOUR_USERNAME/binance_order_info/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/binance_order_info/actions/workflows/flutter_ci.yml)
[![Release CD](https://github.com/YOUR_USERNAME/binance_order_info/actions/workflows/release_cd.yml/badge.svg)](https://github.com/YOUR_USERNAME/binance_order_info/actions/workflows/release_cd.yml)

## ✨ Features

- 📊 **Completed Orders Tracking**: গত 30 দিনের সব completed P2P orders দেখুন
- 💰 **Financial Summary**: Total buy/sell amounts, fees, এবং net profit calculation
- 📈 **Analytics**: Average buy/sell prices, profit percentage
- 🔄 **Real-time Sync**: Backend API থেকে live data fetch
- 📅 **Date-wise Grouping**: Orders date অনুযায়ী organized
- 🔍 **Detailed View**: প্রতিটি transaction এর complete details
- ⚙️ **Configurable**: Custom server IP configuration
- 🎨 **Modern UI**: Clean এবং intuitive Material Design 3

## 🛠️ Tech Stack

- **Framework**: Flutter 3.38.5
- **Language**: Dart 3.10.4
- **State Management**: GetX
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Date Formatting**: intl package

## 📦 Project Structure

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

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.38.5 বা তার উপরে
- Dart SDK 3.10.4 বা তার উপরে
- Android Studio / VS Code
- Backend API server running (default: `http://192.168.0.101:8000`)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/binance_order_info.git
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

### Backend API Setup

এই app একটি backend API এর সাথে communicate করে। Backend API endpoints:

- `GET /api/orders/completed?days=30&use_cache=true` - Completed orders fetch করে
- `GET /api/orders/summary?days=30&use_cache=true` - Summary statistics fetch করে

App settings icon থেকে custom server IP configure করতে পারবেন।

## 📥 Download App

### Option 1: GitHub Releases (Recommended)

Latest stable version download করতে:

1. [Releases page](https://github.com/YOUR_USERNAME/binance_order_info/releases) এ যান
2. Latest release select করুন
3. **Assets** section থেকে আপনার device এর জন্য appropriate APK download করুন:
   - `app-arm64-v8a-release.apk` - বেশিরভাগ modern Android devices (64-bit)
   - `app-armeabi-v7a-release.apk` - পুরানো Android devices (32-bit)
   - `app-x86_64-release.apk` - Intel-based Android devices
4. APK install করুন (Settings → Security → "Install from Unknown Sources" enable করতে হতে পারে)

### Option 2: CI/CD Build Artifacts

Development builds download করতে:

#### Build Branch থেকে:

1. [Actions tab](https://github.com/YOUR_USERNAME/binance_order_info/actions) এ যান
2. **Android Release Build** workflow select করুন
3. সবচেয়ে recent successful run select করুন
4. Scroll down করে **Artifacts** section খুঁজুন
5. `android-release-*` artifact download করুন
6. ZIP extract করে APK file পাবেন

#### Manual Build (Testing):

1. [Actions tab](https://github.com/YOUR_USERNAME/binance_order_info/actions) এ যান
2. **Manual Android Build** workflow select করুন
3. "Run workflow" button click করুন
4. Build type select করুন (Debug/Release)
5. Split APK per ABI enable করুন (smaller file size)
6. Workflow complete হওয়ার পর artifacts download করুন

**Note**: GitHub থেকে artifacts download করতে আপনার repository access থাকতে হবে।

## 🔧 Configuration

### API Configuration

[api_config.dart](lib/config/api_config.dart) file এ default configuration:

```dart
static const String _defaultIp = '192.168.0.101';
static const String _port = '8000';
static const int defaultDays = 30;
static const int timeoutSeconds = 15;
```

Runtime এ app settings থেকে IP address change করতে পারবেন।

## 🏗️ CI/CD Pipeline

Project এ automated CI/CD pipeline setup করা আছে:

### Workflows:

1. **Flutter CI** ([flutter_ci.yml](.github/workflows/flutter_ci.yml))

   - Trigger: `build` branch এ push, PR to `main` বা `build`
   - Actions: Code analysis, tests, debug APK build
   - Artifacts: Debug APK (7 days retention)

2. **Android Release Build** ([release_cd.yml](.github/workflows/release_cd.yml))

   - Trigger: `build` branch এ push অথবা version tag (`v*.*.*`)
   - Actions: Release APK + AAB build, GitHub Release creation
   - Outputs: Multiple APKs (split-per-abi) + AAB
   - Artifacts: 30 days retention

3. **Manual Build** ([manual_build.yml](.github/workflows/manual_build.yml))

   - Trigger: Manual dispatch
   - Options: Debug/Release, Split-per-ABI toggle
   - Flexible testing builds

4. **Security Scan** ([security_scan.yml](.github/workflows/security_scan.yml))
   - Trigger: Push, PR, weekly schedule
   - Actions: Dependency audit, security analysis
   - Reports: Analysis artifacts

### Release Process:

```bash
# Create a new release
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions automatically:
# 1. Builds release APKs + AAB
# 2. Creates GitHub Release
# 3. Uploads all build artifacts
# 4. Generates changelog
```

## 📱 Build Manually

### Debug Build:

```bash
flutter build apk --debug
```

### Release Build:

```bash
# Single APK (larger size, all architectures)
flutter build apk --release

# Split APK per ABI (recommended, smaller sizes)
flutter build apk --release --split-per-abi

# App Bundle for Play Store
flutter build appbundle --release
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## 📄 License

This project is private. All rights reserved.

## 👤 Author

**Your Name**

- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)

## 🤝 Contributing

Contributions, issues এবং feature requests welcome!

Pull request create করার আগে [PR Template](.github/pull_request_template.md) follow করুন।

## 📝 Changelog

### v1.0.0 (Initial Release)

- ✅ Completed orders list
- ✅ Financial summary
- ✅ Transaction details
- ✅ Server IP configuration
- ✅ Date-wise grouping
- ✅ Modern UI with Material Design 3

---

**Note**: এই app শুধু Binance P2P orders track করার জন্য। Trading বা order placement এর জন্য নয়।
