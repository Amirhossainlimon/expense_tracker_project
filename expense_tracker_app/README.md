# Expense Tracker — Flutter + SQLite

A polished personal finance tracker built with Flutter. It supports income and expense records, live summaries, category insights, transaction details, editing, deleting, and persistent local storage using SQLite.

## Features

- Dashboard with **Total Income**, **Total Expense**, and **Current Balance**.
- Recent transaction list and a quick-add button.
- Add and edit forms with title, positive amount, category, type, and date validation.
- Activity screen with search and All / Income / Expense filters.
- Transaction details with Edit and Delete actions.
- Delete confirmation dialog.
- Insights for current-month income/expenses, last-seven-day spending, and category breakdown.
- SQLite storage in `expense_tracker.db`, table `transactions`.
- No login, internet connection, or cloud account required. Records remain on the device.

## Requirements

- Flutter SDK with Dart **3.7 or newer** (compatible with Dart 3.9.x).
- Android Studio / Android SDK for Android builds, or Xcode for iOS builds.
- A physical Android device or emulator is recommended.

## Quick setup on Windows

This source package contains the complete Flutter application code. The setup script creates the standard Android/iOS runner folders with your installed Flutter SDK, then copies the app code into the generated project.

1. Extract this ZIP file.
2. Open PowerShell in the extracted `expense_tracker_project` folder.
3. Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup_project.ps1
```

4. Open the generated `expense_tracker_app` folder in Android Studio or VS Code.
5. Connect an Android phone or start an emulator, then run:

```powershell
cd .\expense_tracker_app
flutter pub get
flutter run
```

To create an APK:

```powershell
flutter build apk --release
```

The APK will be generated at `build\app\outputs\flutter-apk\app-release.apk`.

## Manual setup

Alternatively, create a normal Flutter project with Android and iOS support:

```powershell
flutter create --platforms=android,ios --org com.example expense_tracker_app
```

Copy this package's `lib` and `test` directories, `pubspec.yaml`, and `analysis_options.yaml` into the generated project, replacing the generated files. Then run `flutter pub get` and `flutter run`.

## Database

Database file: `expense_tracker.db`

Table: `transactions`

| Column | SQLite type | Notes |
|---|---|---|
| `id` | INTEGER | Primary key, auto-increment |
| `title` | TEXT | Required |
| `amount` | REAL | Required, greater than zero |
| `category` | TEXT | Required |
| `type` | TEXT | `income` or `expense` |
| `date` | TEXT | ISO-8601 date/time |

The database is created automatically on the first launch. All CRUD operations use parameterized SQLite queries. The app does not clear the database on launch.

## Project structure

```text
lib/
  main.dart
  app.dart
  core/
    constants/app_categories.dart
    theme/app_theme.dart
    utils/formatters.dart
  data/
    database/database_helper.dart
    models/expense_transaction.dart
    providers/transaction_provider.dart
  presentation/
    screens/
      main_shell.dart
      dashboard_screen.dart
      activity_screen.dart
      insights_screen.dart
      transaction_form_screen.dart
      transaction_details_screen.dart
    widgets/
      delete_confirmation.dart
      empty_state.dart
      section_heading.dart
      transaction_tile.dart
test/
  expense_transaction_test.dart
```

## Notes

- Currency is set to Bangladeshi Taka (`৳`). Change the formatter in `lib/core/utils/formatters.dart` to use another currency.
- `sqflite` uses native SQLite support on Android and iOS. This project is intended for Android/iOS, not Flutter Web.
- Compatible dependency pins are used for Dart 3.9.x. In particular, `sqflite 2.4.2` is selected instead of newer releases that require a newer Dart SDK.
