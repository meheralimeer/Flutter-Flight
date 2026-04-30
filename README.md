# 🚀 Flutter Fellowship

Welcome to the **Flutter Fellowship** repository! This project serves as a comprehensive portfolio and learning journal, documenting my journey from Dart fundamentals to advanced Flutter application development.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

---

## 📂 Repository Structure

The repository is organized into progressive tasks, each focusing on specific concepts within the Dart and Flutter ecosystem.

### 🎯 Task 1: Dart - Setup
Focuses on the core building blocks of the Dart programming language.
- `01_basics`: Variables, data types, and operators.
- `02_functions`: Function definitions, parameters, and arrow syntax.
- `03_collections`: Lists, Maps, and Sets.
- `04_null_safety`: Understanding and implementing sound null safety.

### 📱 Task 2: Auth UIs
Initial foray into Flutter development, exploring authentication-related UI screens and layouts.

### 🍲 Task 3: CookBook - UIs
A functional "Cookbook" application demonstrating recipe detail screens with custom UI components.
- Custom widgets (badges, rating stars, section headers).
- Cached network images and favorites via SharedPreferences.
- Styled recipe detail view with ingredients checklist and step-by-step instructions.

### 🔌 Task 4: CookBook - API Updation
An upgraded version of the CookBook app that replaces static sample data with **TheMealDB API** integration.
- **API Integration**: Search meals, browse categories, random meal discovery.
- **TheMealDB Endpoints**: `search.php`, `lookup.php`, `random.php`, `categories.php`, `filter.php`.
- **Screens**: Home (categories + random), Category meals list, Meal detail, Search.
- **Features**: Debounced search, ingredient checklist, YouTube video links, favorites.

### 📅 Task 5: GDG App
A robust application designed for managing Google Developer Group (GDG) activities.
- **Firebase Integration**: Authentication, Firestore, and attendance tracking.
- **Role-based Screens**: Feedback, attendance history, and team management.
- **Modern UI**: Dashboard tiles and real-time updates.

### 🏠 Task 6: Home Automation
An IoT-focused application for managing home devices via MQTT protocol.
- **MQTT Communication**: Publishing and subscribing to device topics.
- **Real-time Updates**: Status monitoring for Lights, AC, and Fans.
- **Clean Architecture**: Service-oriented design with state management (Riverpod/Bloc).

---

## 🛠 Tech Stack

- **Language**: [Dart](https://dart.dev)
- **Framework**: [Flutter](https://flutter.dev)
- **APIs**: TheMealDB (Task 4)
- **Backend/Services**: Firebase (Auth, Firestore), MQTT Broker (HiveMQ/Local)
- **State Management**: Providers, Riverpod, or Bloc (varies by task)

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest Stable)
- [Dart SDK](https://dart.dev/get-started/sdk)
- An IDE (VS Code, Android Studio)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/meheralimeer/Flutter-Flight.git
   cd Flutter-Flight
   ```

2. **Setup Task-specific dependencies**:
   Navigate to any task directory (e.g., `task4`) and run:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

---

## 📏 Code Guidelines

To maintain consistency, all contributions and task implementations follow the guidelines outlined in [AGENTS.md](./AGENTS.md).

- **Formatting**: Use `flutter format .`
- **Linting**: No warnings in `flutter analyze`
- **Naming**: `snake_case` for files, `PascalCase` for classes.

---

## 📈 Roadmap

- [x] Dart Fundamentals (Task 1)
- [x] Auth UIs (Task 2)
- [x] CookBook UIs (Task 3)
- [x] CookBook API Updation (Task 4)
- [x] GDG App (Task 5)
- [x] Home Automation (Task 6)

---

## 👨‍💻 Author

**Meher Ali Meer**
*Flutter Fellowship Participant*

---

*Made with ❤️ and Flutter.*
