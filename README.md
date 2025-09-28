# CoinGlass Flutter App

A Flutter implementation of a CoinGlass-style cryptocurrency analytics dashboard. The app shows market metrics, funding rates, and liquidation statistics with graceful fallbacks when the public CoinGlass API is not reachable.

## Overview

- **App name:** `coinglass_app`
- **Current version:** `1.0.0+1`
- **Tech stack:** Flutter (Material 3), GetX for state management, `http` for REST calls, and `intl` for formatting utilities.
- **Supported platforms:** Android, iOS, web, and macOS (standard Flutter targets).

## Features

- Dashboard with cards for the most active perpetual futures pairs.
- Funding rate overview across multiple exchanges.
- Liquidation statistics with long/short distribution bars.
- Pull-to-refresh and retry flows to handle transient network failures.
- Sample data baked in as a fallback when the API is unavailable or an API key has not been provided.

## Prerequisites

- Flutter SDK **3.10.0 or newer** (Dart SDK `>=2.19.0 <4.0.0`).
- A configured device or emulator for your target platform (Android Studio, Xcode, Chrome, etc.).
- (Optional) A CoinGlass API secret for live data.

Verify your Flutter installation:

```bash
flutter --version
```

## Getting Started

1. Install the dependencies:

   ```bash
   flutter pub get
   ```

2. Run the app on your preferred device:

   ```bash
   flutter run
   ```

3. (Optional) Provide your CoinGlass API secret to unlock live data:

   ```bash
   flutter run --dart-define=COINGLASS_SECRET=YOUR_KEY_HERE
   ```

   Without an API key the dashboard will load the bundled sample data so you can still preview the UI offline.

### Platform-specific commands

- **Web:** `flutter run -d chrome`
- **Android:** `flutter run -d android`
- **iOS/macOS:** open the generated Xcode project or run `flutter run -d ios` / `flutter run -d macos` on macOS with Xcode installed.

## Project Structure

```
lib/
  main.dart              # App entry point
  src/
    app.dart             # MaterialApp configuration and theming
    theme.dart           # Shared theme helper
    data/
      models.dart        # Data model classes
      coinglass_api.dart # REST client with graceful fallbacks
      sample_data.dart   # Offline sample payloads
    presentation/
      home_screen.dart   # Main dashboard experience
```

## Notes

- The REST endpoints rely on the public CoinGlass API. If the API changes, adjust the `_map*` helpers in `coinglass_api.dart` accordingly.
- The repository uses `flutter_lints`. Run `flutter analyze` to check for lint issues once Flutter is installed locally.
