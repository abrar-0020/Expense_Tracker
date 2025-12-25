# 📱 Expense Tracker

A modern, clean, and fully offline mobile expense tracker built with Flutter. Perfect for college projects and internship demonstrations.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

## 📥 Download

**[📲 Download APK](https://drive.google.com/file/d/1SQ4o6oeKhaAQ-Arz2D0Xi3tfniNa7eG_/view?usp=drivesdk)** - Direct download for Android

> **Note:** For first-time installation, you may need to enable "Install from Unknown Sources" in your Android settings.

## ✨ Features

- **100% Offline** - No internet required, all data stored locally
- **Modern UI** - Clean, minimalist design with soft shadows and rounded cards
- **Expense Management** - Add, view, and delete expenses with ease
- **Category System** - 8 predefined categories with custom icons and colors
- **Monthly Summary** - Visual breakdown of expenses by category
- **Data Persistence** - SQLite database for reliable local storage
- **Clean Architecture** - Separated layers (UI, Service, Database)

## 🎨 UI Design Philosophy

- **Light Background Theme** - White and very light grey backgrounds
- **Minimalist Design** - No clutter, focus on usability
- **Rounded Cards** - Modern card-based layout throughout
- **Soft Shadows** - Subtle depth without overwhelming
- **Clear Typography** - Easy to read text hierarchy
- **Good Spacing** - Comfortable padding and margins
- **Professional Look** - Similar to modern finance apps

## 🏗️ Architecture

### Three-Layer Architecture

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  - Screens (Home, Add, View, etc.)  │
│  - Widgets (Reusable components)    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Business Logic Layer             │
│  - Services (ExpenseService)        │
│  - Models (Expense, CategorySummary)│
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Data Layer                     │
│  - Database Helper (SQLite)         │
│  - Local Storage                    │
└─────────────────────────────────────┘
```

### Data Flow

```
User Action → Screen → Service → Database Helper → SQLite
                ↓         ↓            ↓
            Widget ← Model ← Query Result
```

## 📁 Project Structure

```
expense_tracker/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   │   ├── expense.dart             # Expense model
│   │   └── category_summary.dart    # Category summary model
│   ├── database/                    # Database layer
│   │   └── database_helper.dart     # SQLite operations
│   ├── services/                    # Business logic
│   │   └── expense_service.dart     # Expense operations
│   ├── screens/                     # UI screens
│   │   ├── home_screen.dart         # Main dashboard
│   │   ├── add_expense_screen.dart  # Add expense form
│   │   ├── view_expenses_screen.dart# List all expenses
│   │   └── summary_screen.dart      # Category breakdown
│   ├── widgets/                     # Reusable widgets
│   │   └── expense_card.dart        # Expense card widget
│   └── utils/                       # Utilities
│       ├── constants.dart           # App constants
│       └── format_utils.dart        # Formatting helpers
└── pubspec.yaml                     # Dependencies
```

## 🗄️ Database Schema

### Expenses Table

```sql
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  description TEXT
);

-- Indexes for performance
CREATE INDEX idx_date ON expenses(date);
CREATE INDEX idx_category ON expenses(category);
```

### Fields Description

| Field       | Type    | Description                    |
|-------------|---------|--------------------------------|
| id          | INTEGER | Auto-increment primary key     |
| amount      | REAL    | Expense amount                 |
| category    | TEXT    | Category name (Food, Transport)|
| date        | TEXT    | ISO 8601 date string           |
| description | TEXT    | Optional expense description   |

## 🎯 Categories

The app includes 8 predefined categories with custom icons and colors:

1. **Food** 🍽️ - #FFB6B9
2. **Transport** 🚗 - #BAE1FF
3. **Shopping** 🛍️ - #FFDFB9
4. **Entertainment** 🎬 - #CDB4DB
5. **Bills** 🧾 - #FFAFCC
6. **Health** 🏥 - #A8DADC
7. **Education** 📚 - #F1C0E8
8. **Other** 📦 - #B8E0D2

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation Steps

1. **Clone or download this project**
   ```bash
   cd "C:\Users\Dell\Downloads\Projects\expense tracker"
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

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Screens Overview

### 1. Home Screen
- Monthly total display
- Quick stats (total expenses, current month)
- Quick action buttons
- Floating action button to add expense

### 2. Add Expense Screen
- Amount input with validation
- Category selector (grid layout)
- Date picker
- Optional description field
- Save button with loading state

### 3. View Expenses Screen
- List of all expenses
- Swipe to delete functionality
- Pull to refresh
- Empty state handling
- Dismissible cards

### 4. Summary Screen
- Monthly total card
- Visual progress bars by category
- Category-wise breakdown
- Expense count per category

## 🔧 Technical Details

### Dependencies

- **sqflite** (^2.3.0) - SQLite plugin for Flutter
- **path** (^1.8.3) - Path manipulation utilities
- **intl** (^0.18.1) - Internationalization and date formatting

### Key Features Implementation

#### Singleton Pattern (Database)
```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
}
```

#### Service Layer Pattern
```dart
class ExpenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // All business logic here
}
```

#### State Management
- StatefulWidget for dynamic screens
- setState for local state updates
- Async/await for database operations

## 🎓 Learning Outcomes

This project demonstrates:

1. **Clean Architecture** - Separation of concerns
2. **Database Operations** - SQLite CRUD operations
3. **State Management** - Flutter state handling
4. **UI/UX Design** - Modern mobile UI patterns
5. **Data Modeling** - Proper model design
6. **Error Handling** - Try-catch blocks
7. **Async Programming** - Future and async/await
8. **Form Validation** - Input validation
9. **Navigation** - Screen routing
10. **Widget Composition** - Reusable widgets

## 🔐 Privacy & Security

- **100% Offline** - No data leaves your device
- **No Analytics** - No tracking or telemetry
- **No Permissions** - Only storage access (for SQLite)
- **Open Source** - Complete transparency

## 🤝 Contributing

This is a college/internship project template. Feel free to:
- Fork and modify for your needs
- Add new features
- Improve UI/UX
- Add more categories
- Implement export functionality

## 📝 License

This project is created for educational purposes and is free to use.

## 👨‍💻 Author

Created as a demonstration of Flutter development skillsA feature-rich Flutter expense tracking app with budget management, analytics charts, calculator, search & sort. Offline-first with SQLite storage. 💰📊

## 🔮 Future Enhancements

Possible improvements:
- Export data to CSV/PDF
- Backup and restore functionality
- Recurring expenses
- Multi-user support

---

**Made with ❤️ using Flutter**
