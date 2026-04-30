# GDG Management App Setup Guide

This guide will help you run the GDG Management App on your local machine.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10.0 or higher recommended)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- Firebase Account (for setting up your own backend if needed)

## 1. Fetch Dependencies

Open your terminal in the `task3/gdg_app` directory and run:

```bash
flutter pub get
```

## 2. Firebase Configuration (Optional but Recommended)

The app comes with a default `firebase_options.dart`. However, for full functionality (especially if the default project reaches its limits), you should:

1. Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password** Authentication.
3. Enable **Cloud Firestore** and create a database.
4. Use the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) to reconfigure the project:
   ```bash
   flutterfire configure
   ```
   This will update `lib/firebase_options.dart` with your own credentials.

### Firestore Rules
Ensure your Firestore rules allow read/write access during development:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 3. Running the App

### Run on Linux Desktop
```bash
flutter run -d linux
```

### Run on Android
```bash
flutter run -d <your-device-id>
```

### Run on WebdistributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip

```bash
flutter run -d chrome
```

## Troubleshooting

- **Analysis Errors**: Run `flutter analyze` to check for any issues.
- **Build Fails**: Run `flutter clean` then `flutter pub get` and try again.
- **Firebase Issues**: Check your internet connection and ensure `firebase_options.dart` is correctly configured.
