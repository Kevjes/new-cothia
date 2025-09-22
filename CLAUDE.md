# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

- **Run the app**: `flutter run`
- **Build for release**: `flutter build apk` or `flutter build ios`
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`
- **Install dependencies**: `flutter pub get`
- **Clean build files**: `flutter clean`

## Architecture Overview

This is a Flutter app using **GetX** for state management, routing, and dependency injection. The app follows a modular architecture:

### Core Structure
- **GetX Pattern**: Controllers extend `GetxController`, use `.obs` for reactive state
- **Service Layer**: Persistent services registered in `AppBinding` with `permanent: true`
- **Firebase Backend**: Authentication, Firestore for data persistence
- **Dual Theme Support**: Light/dark themes via `AppTheme` class, managed by `ThemeService`

### Key Services
- `ThemeService`: Theme management with persistence
- `AuthService`: Firebase authentication
- `FinanceService`: Core financial data operations
- `AccountsService`: Account-specific operations
- `BudgetsService`: Budget management

### Feature Structure
```
lib/app/features/[feature]/
├── controllers/     # GetX controllers
├── views/          # UI pages and widgets
├── models/         # Data models
└── bindings/       # Dependency injection
```

## Code Style Guidelines

- **Theme Access**: Use `Get.theme` instead of `Theme.of(context)`
- **Type Safety**: Avoid dynamic variables, type all function parameters
- **Navigation**: Use `AppRoutes` constants, never hardcode routes: `Get.toNamed(AppRoutes.MY_PAGE)`
- **UI Pattern**: Create full pages instead of BottomSheets for better UX
- **Dual Theme Support**: Ensure all widgets support both light and dark themes
- **GetX Patterns**:
  - Access controllers via `ControllerName.to` (e.g., `FinanceController.to`)
  - Use reactive variables with `.obs` and `.value`
  - Stream subscriptions in controllers should be cancelled in `onClose()`

## Navigation

Routes are centralized in `AppRoutes` class. Main modules:
- Finance module with nested routes for accounts, budgets, transactions
- Authentication flow
- Home dashboard

Always use the constants from `AppRoutes` for navigation.