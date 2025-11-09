# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based Point of Sale (POS) application called "Todou App" that handles multiple payment methods including Stripe card payments, Stripe Tap to Pay (NFC), mobile money payments (Orange Money, Wave), and QR code payments. The app targets merchants and terminals for processing transactions.

**Technology Stack:**
- Flutter 3.35.4 / Dart 3.9.2
- State Management: flutter_bloc (BLoC pattern)
- Network: Dio & http client
- Payment Processing: Stripe Terminal SDK (mek_stripe_terminal), flutter_stripe
- Secure Storage: flutter_secure_storage
- Environment: flutter_dotenv (.env file)

## Development Commands

### Running the App
```bash
# Run on connected device/simulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run with specific flavor (if configured)
flutter run --debug
flutter run --release
```

### Building
```bash
# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Build iOS
flutter build ios

# Build for release with optimization
flutter build apk --release
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Fix common issues automatically
dart fix --apply
```

### Dependency Management
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Clean build artifacts
flutter clean && flutter pub get
```

### Platform-Specific Commands
```bash
# Android - Generate icons and splash screens
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# View Android logs
flutter logs
```

## Modes d'Exécution (Mock/Prod)

L'application supporte deux modes d'exécution configurables via variable d'environnement:

### Mode Mock (Développement sans backend)

Permet de développer et tester l'application sans connexion au backend. Toutes les données proviennent de sources mockées.

**Configuration:**
```env
# .env
APP_MODE=mock
```

**Caractéristiques:**
- Aucun appel API réel
- Données fictives cohérentes et réalistes
- Simulation de latence réseau (500ms-1500ms)
- Stripe désactivé
- Identifiants de test:
  - Code terminal: N'importe quel code non vide
  - OTP: `1234`

**Données mockées disponibles:**
- Balance: 1 250 000 XOF
- 4 transactions de test (success, failed, pending)
- Profil fictif du terminal
- Paiements mobiles simulés (Orange Money, Wave)
- Paiements Stripe simulés

**Utilisation:**
```bash
# S'assurer que APP_MODE=mock dans .env
flutter run
```

### Mode Production

Se connecte au vrai backend API.

**Configuration:**
```env
# .env
APP_MODE=prod
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

**Caractéristiques:**
- Appels API réels
- Stripe activé et configuré
- Authentification requise
- Données réelles du backend

**Utilisation:**
```bash
# S'assurer que APP_MODE=prod dans .env
flutter run
```

### Architecture du Système Mock/Prod

**Service Locator avec get_it:**
- DI centralisé dans `core/di/injection.dart`
- Chaque feature a son propre module DI: `features/[feature]/di/injection.dart`
- Ordre d'injection: Core → Features

**Pattern par feature:**
```
features/[feature]/
├── di/
│   └── injection.dart                 # Future<void> setup[Feature]Feature()
├── data/
│   ├── datasources/
│   │   ├── i_[feature]_data_source.dart          # abstract interface class
│   │   ├── [feature]_remote_data_source.dart     # implémente I[Feature]DataSource
│   │   └── [feature]_mock_data_source.dart       # implémente I[Feature]DataSource
│   └── repositories/
│       └── [feature]_repository_impl.dart        # utilise I[Feature]DataSource
├── domain/
│   ├── repositories/
│   │   └── i_[feature]_repository.dart           # abstract class I[Feature]Repository
│   └── usecases/
└── presentation/
```

**Conventions de nommage:**
- Interfaces: préfixe `I` (ex: `IAuthDataSource`, `IAuthRepository`)
- Remote: `AuthRemoteDataSource`, `TransactionRemoteDataSource`
- Mock: `AuthMockDataSource`, `TransactionMockDataSource`
- Propriétés privées: `_dataSource`, `_networkInfo`, `_apiClient`

**Données mockées:**
- Centralisées dans `core/mock/mock_data.dart`
- Helpers dans `core/mock/mock_helpers.dart` (latence, erreurs simulées)

**Exemple d'injection par feature:**
```dart
// features/auth/di/injection.dart
Future<void> setupAuthFeature() async {
  // DATA SOURCE (choix Mock vs Prod)
  if (AppConfig.isMockMode) {
    sl.registerLazySingleton<IAuthDataSource>(() => AuthMockDataSource());
  } else {
    sl.registerLazySingleton<IAuthDataSource>(
      () => AuthRemoteDataSource(apiClient: sl()),
    );
  }

  // REPOSITORY (agnostique de la source)
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      dataSource: sl<IAuthDataSource>(),
      networkInfo: sl<INetworkInfo>(),
    ),
  );

  // USE CASES + BLOC...
}
```

## Architecture

This app follows **Clean Architecture** principles with a feature-based folder structure:

### Layer Structure
```
lib/
├── core/                    # Shared utilities and infrastructure
│   ├── constants/          # API endpoints, routes, colors, app constants
│   ├── errors/             # Custom exceptions and failure classes
│   ├── network/            # API client with token management and interceptors
│   ├── stripe/             # Stripe Terminal manager and event handlers
│   ├── utils/              # Helpers (payment, navigation, secure storage, token validation)
│   └── widgets/            # Reusable UI components (buttons, keyboard, headers)
│
└── features/               # Feature modules (Clean Architecture layers)
    ├── auth/               # Authentication (OTP-based login)
    ├── home/               # Home/Dashboard
    ├── mobile_payments/    # Mobile money (Orange Money, Wave)
    ├── nfc/                # NFC/Tap to Pay functionality
    ├── payments/           # Stripe card payments and link payments
    ├── profil/             # User profile
    └── transactions/       # Transaction history and balance
```

### Each Feature Module Contains:
- **data/** - Data sources, models, repository implementations
  - `datasources/` - Remote API calls
  - `models/` - Data models with JSON serialization
  - `repositories/` - Repository implementations
- **domain/** - Business logic layer
  - `repositories/` - Repository interfaces
  - `usecases/` - Single-responsibility use cases
- **presentation/** - UI layer
  - `bloc/` - BLoC state management (events, states, bloc)
  - `pages/` - Screen widgets

### Key Architectural Patterns

**BLoC Pattern**: All state management uses flutter_bloc with events, states, and blocs separated into files.

**Repository Pattern**: Domain layer defines repository interfaces, data layer implements them. Repositories handle network calls and error handling via the `Either<Failure, T>` pattern from dartz.

**Use Cases**: Each business operation is encapsulated in a single-responsibility use case class (e.g., `VerifyCode`, `InitPayment`, `GetTransactions`).

**Dependency Injection**: Manual dependency injection in main.dart - all BLoCs are provided at the app level via MultiBlocProvider with repositories and use cases passed to constructors.

### ⚠️ RÈGLE ARCHITECTURALE CRITIQUE - SÉPARATION DES COUCHES

**INTERDICTION ABSOLUE** : La couche Présentation ne doit JAMAIS appeler directement les services de la couche Data/Infrastructure.

**❌ INTERDIT** :
```dart
// ❌ MAUVAIS - Violation de Clean Architecture
class MyWidget extends StatelessWidget {
  final SecureStorageService _storage = sl<SecureStorageService>(); // ❌ NE JAMAIS FAIRE
  final ApiClient _apiClient = sl<ApiClient>(); // ❌ NE JAMAIS FAIRE
}
```

**✅ OBLIGATOIRE - Flux Clean Architecture** :
```
UI (Présentation) → BLoC → UseCase → Repository → DataSource/Service
```

**Exemple correct** :
```dart
// ✅ BON - Respect de Clean Architecture

// 1. Domain - Interface Repository
abstract class IOnboardingRepository {
  Future<bool> hasCompletedOnboarding();
  Future<void> completeOnboarding();
}

// 2. Domain - Use Case
class CompleteOnboarding {
  final IOnboardingRepository _repository;
  CompleteOnboarding(this._repository);
  Future<void> call() => _repository.completeOnboarding();
}

// 3. Data - Repository Implementation
class OnboardingRepositoryImpl implements IOnboardingRepository {
  final SecureStorageService _secureStorage; // ✅ OK ici (couche Data)

  OnboardingRepositoryImpl({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  Future<void> completeOnboarding() => _secureStorage.setOnboardingCompleted();
}

// 4. Presentation - BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboarding _completeOnboarding; // ✅ Use case uniquement

  OnboardingBloc({required CompleteOnboarding completeOnboarding})
      : _completeOnboarding = completeOnboarding;

  void _onComplete() async {
    await _completeOnboarding(); // ✅ Appel du use case
  }
}

// 5. Presentation - UI
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>( // ✅ BLoC uniquement
      builder: (context, state) {
        // UI écoute le BLoC, jamais de service direct
        return ElevatedButton(
          onPressed: () {
            context.read<OnboardingBloc>().add(CompleteEvent()); // ✅ Event BLoC
          },
        );
      },
    );
  }
}
```

**Référence d'implémentation** : Voir `features/onboarding/` pour un exemple complet conforme à cette règle.

### Authentication & Security

**Token Management**:
- Tokens stored in flutter_secure_storage
- Token validation happens in ApiClient before each authenticated request
- TokenValidator checks JWT expiration
- TokenExpiredEvent triggers automatic logout via event_bus
- Main.dart initializes the app checking token validity on startup

**API Client** (`core/network/api_client.dart`):
- Wraps http.Client with automatic token injection
- Handles authentication and token expiration
- Throws `ServerException` on API errors
- Supports both authenticated and public endpoints

**Authentication Flow**:
1. User enters terminal ID
2. OTP sent to merchant
3. OTP verification returns JWT token
4. Token stored securely and added to all subsequent requests

### Payment Processing

**Stripe Payments** (`features/payments/`):
- Card payments via flutter_stripe SDK
- Payment Intent creation via backend
- Stripe Terminal integration for physical card readers
- Link payment (QR code) generation

**Mobile Money** (`features/mobile_payments/`):
- Supports Orange Money and Wave
- Payment initialization returns transaction ID
- Background verification with PaymentVerificationHandler polling
- QR code display for Wave payments
- 180-second timeout with countdown

**Tap to Pay/NFC** (`features/nfc/`):
- Uses mek_stripe_terminal plugin
- Custom MethodChannel integration for native Stripe Terminal SDK
- Reader discovery and connection management
- NFC card reading for contactless payments

**Transaction Verification**:
- `PaymentVerificationHandler` in `core/utils/payment_verification_handler.dart` handles automatic payment status polling
- Timer-based verification every 10 seconds
- Emits state updates via BLoC

### Routing

Routes defined in `core/constants/route_constants.dart` and configured in main.dart:
- Named routes via MaterialApp
- Arguments passed via ModalRoute.of(context)!.settings.arguments
- navigatorKey for programmatic navigation
- routeObserver for route lifecycle tracking

### Environment Configuration

**.env file** contains:
- STRIPE_PUBLISHABLE_KEY
- STRIPE_SECRET_KEY

Loaded at app startup with `flutter_dotenv`.

### Backend Integration

**Base URL**: `https://tyure-backend-dev.todoustudio.cloud/api/v1`

**Key Endpoints**:
- `/merchants/terminals/request-otp` - Request OTP for terminal
- `/merchants/terminals/verify-otp` - Verify OTP and get token
- `/auth/merchants/` - Get balance and transactions (requires auth)
- `/merchants/transactions/init-payment/mobile-money` - Initialize mobile payment
- `/merchants/transactions/init-payment/card` - Create Stripe payment intent
- `/merchants/transactions/init-payment/card/link` - Create Stripe link payment

All endpoints use JSON with automatic token injection for authenticated routes.

## Important Implementation Notes

**State Management**:
- Always use BLoC pattern for state management
- Events trigger state changes
- UI listens to BLoC states via BlocBuilder/BlocListener
- Never store UI state in widgets - use BLoC

**Error Handling**:
- Network errors wrapped in `Failure` classes (from dartz)
- Use `Either<Failure, Success>` pattern in repositories
- ServerException thrown from ApiClient, converted to Failure in repositories
- Display user-friendly messages via custom_snackbar

**Testing**:
- bloc_test and mocktail available for testing
- Test files should mirror lib/ structure

**Platform-Specific**:
- Android minSdk: 26, targetSdk: 33
- ProGuard enabled for release builds with custom exclusions for BouncyCastle
- Stripe Terminal requires additional native setup

**Security**:
- Never commit .env file with real keys
- Token validation occurs before each authenticated API call
- Secure storage handles token encryption at OS level

**Navigation**:
- Use named routes for consistency
- Global navigatorKey for programmatic navigation outside BuildContext
- Always pass route arguments via settings.arguments
