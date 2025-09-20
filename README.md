# CoinGlass Flutter App

A Flutter implementation of a CoinGlass-style cryptocurrency analytics dashboard. The app shows market metrics, funding rates, and liquidation statistics with graceful fallbacks when the public CoinGlass API is not reachable.

## Features

- Dashboard with cards for the most active perpetual futures pairs.
- Funding rate overview across multiple exchanges.
- Liquidation statistics with long/short distribution bars.
- Pull-to-refresh and retry flows to handle transient network failures.
- Sample data baked in as a fallback when the API is unavailable or an API key has not been provided.

## Getting Started

1. Install Flutter (3.10 or newer is recommended).
2. Fetch packages:

   ```bash
   flutter pub get
   ```

3. (Optional) Create a `--dart-define` with your CoinGlass API secret to unlock live data:

   ```bash
   flutter run --dart-define=COINGLASS_SECRET=YOUR_KEY_HERE
   ```

   Without an API key the dashboard will load the bundled sample data so you can still preview the UI offline.

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
