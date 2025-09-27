# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cothia is a holistic life management application built with Flutter and GetX, integrating three core modules: Entity Management, Finance Management, and Performance/Habits tracking. The app uses Firebase as the backend and follows a feature-first architecture with clean code principles.

## Technology Stack

- **Frontend**: Flutter with GetX for state management
- **Backend**: Firebase (Auth, Firestore)
- **Architecture**: Feature-first structure with clean architecture layers
- **Theme**: Dark theme exclusively with blue primary and orange secondary colors
- **Local Storage**: SharedPreferences for authentication persistence

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app in development
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Run tests
flutter test

# Analyze code
flutter analyze

# Clean build files
flutter clean
```

## Architecture & Code Structure

### Feature-First Architecture
```
lib/
├── app/
│   ├── core/                    # Core utilities, constants, themes
│   │   ├── constants/
│   │   ├── themes/
│   │   ├── utils/
│   │   └── services/            # Global services (AppBinding)
│   ├── data/                    # Data layer
│   │   ├── models/              # Data models
│   │   ├── repositories/        # Repository implementations
│   │   └── services/            # API services
│   ├── features/                # Feature modules
│   │   ├── auth/               # Authentication feature
│   │   ├── entities/           # Entity management
│   │   ├── finance/            # Finance management
│   │   └── performance/        # Tasks and habits
│   ├── modules/                # GetX modules (legacy structure)
│   └── routes/                 # App routing
├── firebase_options.dart       # Firebase configuration
└── main.dart
```

### Module Structure (Feature-First)
Each feature follows this structure:
```
features/[feature_name]/
├── bindings/          # GetX bindings
├── controllers/       # GetX controllers
├── models/           # Feature-specific models
├── repositories/     # Data access layer
├── services/         # Feature services
├── views/            # UI components
│   ├── pages/        # Full screen pages
│   └── widgets/      # Reusable widgets
└── [feature_name]_module.dart
```

## Core Business Logic

### Entity Management (Foundation Module)
- **Personal Entity**: Automatically created on user registration
- **Custom Entities**: Users can create entities for organizations, companies, etc.
- **Default Selection**: Personal entity is auto-selected in forms but can be changed
- **Scope**: All projects, tasks, transactions, and budgets are linked to entities

### Authentication Flow
- Email/password authentication with Firebase
- Local persistence using SharedPreferences
- Automatic personal entity creation on first registration
- Auto-login on app launch if authenticated

### UI/UX Guidelines

#### Design System
- **Theme**: Dark theme exclusively
- **Colors**: Blue primary (#main_blue), Orange secondary (#accent_orange)
- **Loading**: Use shimmer effects for all loading states
- **Navigation**: Feature drawers with sub-module lists

#### Page Structure
- **Overview/Dashboard**: Each module has a main overview page with quick actions
- **CRUD Operations**: Use full pages instead of modals/dialogs
- **Form Behavior**: Close form pages and return to previous page after submission
- **Responsive**: All components must be responsive

#### Navigation Patterns
- Module Overview → Sub-module pages → Detail/CRUD pages
- Always provide back navigation
- Use GetX named routes for navigation

## Firebase Integration

### Authentication
- Email/password authentication
- User profile stored in Firestore
- Personal entity auto-created with userId reference

### Firestore Collections Structure
```
users/
  {userId}/
    - email
    - createdAt
    - personalEntityId

entities/
  {entityId}/
    - name
    - type (personal/organization)
    - ownerId
    - createdAt

projects/
  {projectId}/
    - name
    - entityId
    - description
    - createdAt

# Additional collections for finance, tasks, etc.
```

## Development Guidelines

### Code Style
- Follow clean architecture principles
- Use GetX patterns: Controller → Service → Repository
- Implement proper error handling with try-catch blocks
- Use meaningful variable and function names
- No hardcoded strings - use constants or localization

### State Management
- Use GetX controllers for business logic
- Reactive programming with Obx() for UI updates
- Dependency injection through GetX bindings

### Error Handling
- Global error handling in services layer
- User-friendly error messages
- Loading states for all async operations

### Testing Strategy
- Unit tests for business logic (controllers, services)
- Widget tests for UI components
- Integration tests for critical user flows

## Module Development Priority

1. **Entity Management** (Foundation - Required first)
2. **Authentication System** (Core functionality)
3. **Finance Module** (Primary business value)
4. **Performance/Tasks Module** (Secondary priority)
5. **Habits Module** (Enhancement feature)

## Security Considerations

- Never commit Firebase keys or secrets
- Validate all user inputs
- Implement proper Firestore security rules
- Use proper authentication checks in all protected routes
- Sanitize data before saving to Firestore

## Performance Optimization

- Use const constructors where possible
- Implement lazy loading for large lists
- Optimize Firestore queries with proper indexing
- Use GetX's lazy loading for controllers
- Implement proper dispose methods to prevent memory leaks
- L'expérience utilisateur doit être le plus optimale possible, 
Livrer module par module 
design beau et épurer (theme Dark exclusivement) et utilisation des shimmer pour les chargements
UI: Pour chaque Module (exemple du module finance) ou sous module (Exemple du sous module des transaction), on doit avoir un Overview (ou Dashboard) page qui contient les actions rapide sur le module et un aperçu rapide du module, 
UI : Chaque module doit avoir un drawer avec le Menu etant la liste de ses sous modules
UI : Utiliser des pages pour les CRUD et non des ModalSheets ou Dialogs et se rassurer qu’apres validation, la page du formulaire se ferme pour nous renvoyer a la page précédent,
UI: Se rassurer que les formulaires sont intuitifs moderne et User friendly
- toujours utiliser AppRoutes . A la place de Get.toNamed("/tasks"), utiliser AppRoutes comme suit : Get.toNamed(AppRoutes.TASKS)
- toujours analyser les erreurs et les corriger toutes avant de confirmer une fonctionnalité