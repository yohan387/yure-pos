# Architecture Complète - Todou POS App

## Vue d'ensemble

Application Flutter POS (Point of Sale) suivant les principes de **Clean Architecture** avec séparation en 3 couches distinctes par feature.

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                       │
│  ┌────────────┐  ┌──────────────┐  ┌─────────────────────────┐ │
│  │   Pages    │→→│    BLoCs     │→→│   Events / States       │ │
│  │  (Widgets) │  │ (Business    │  │   (Equatable)           │ │
│  │            │  │  Logic)      │  │                         │ │
│  └────────────┘  └──────────────┘  └─────────────────────────┘ │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                            │
│  ┌────────────────────┐           ┌──────────────────────────┐ │
│  │  Use Cases         │           │  Repository Interfaces   │ │
│  │ (Single Resp.)     │    →→     │  (Contracts)             │ │
│  └────────────────────┘           └──────────────────────────┘ │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                             │
│  ┌──────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │  Repository      │  │  Data Sources  │  │    Models      │ │
│  │  Implementations │→→│  (Remote API)  │  │  (JSON ↔ Obj)  │ │
│  └──────────────────┘  └────────────────┘  └────────────────┘ │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ↓
                    ┌─────────────────┐
                    │   CORE LAYER    │
                    │  (Shared Utils) │
                    └─────────────────┘
```

---

## Structure des Dossiers

```
lib/
├── core/                                    # Infrastructure partagée
│   ├── constants/                           # Constantes globales
│   │   ├── api_constants.dart              # URLs, endpoints, headers
│   │   ├── route_constants.dart            # Routes nommées
│   │   ├── colors.dart                     # Palette de couleurs
│   │   ├── app_constants.dart              # Config app
│   │   └── gateway_list.dart               # Liste des passerelles
│   │
│   ├── errors/                              # Gestion des erreurs
│   │   ├── exceptions.dart                 # ServerException, TokenExpiredException
│   │   └── failures.dart                   # Failure, NetworkFailure, ServerFailure
│   │
│   ├── network/                             # Couche réseau
│   │   ├── api_client.dart                 # Client HTTP + token injection + idempotence
│   │   ├── api_interceptor.dart            # Intercepteurs
│   │   └── network_info.dart               # Vérification connectivité
│   │
│   ├── stripe/                              # Stripe Terminal
│   │   ├── stripe_terminal_manager.dart    # Gestion Stripe Terminal
│   │   └── stripe_terminal_events.dart     # Événements Stripe
│   │
│   ├── utils/                               # Utilitaires
│   │   ├── idempotency_key_manager.dart    # 🆕 Gestion clés idempotence (UUID v4)
│   │   ├── secure_storage.dart             # Stockage sécurisé (tokens)
│   │   ├── token_validator.dart            # Validation JWT
│   │   ├── event_bus.dart                  # Bus événements (TokenExpiredEvent)
│   │   ├── navigation.dart                 # NavigatorKey global
│   │   ├── payment_helper.dart             # Helpers paiement
│   │   ├── payment_verification_handler.dart # Polling vérification paiement
│   │   ├── amout_format.dart               # Formatage montants
│   │   ├── convert_stripe_amount.dart      # Conversion centimes Stripe
│   │   └── dialog_helper.dart              # Helpers dialogues
│   │
│   └── widgets/                             # Composants UI réutilisables
│       ├── button_widget.dart
│       ├── custom_snackbar.dart
│       ├── keyboard.dart
│       ├── my_app_bar.dart
│       ├── header.dart
│       └── page_loader.dart
│
└── features/                                # Modules métier (Clean Architecture)
    │
    ├── auth/                                # 🔐 Authentification OTP
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── auth_remote_data_source.dart      # API: request-otp, verify-otp
    │   │   ├── models/
    │   │   │   └── auth_response_model.dart          # AuthResponse, OtpResponse
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart         # Implémentation
    │   │
    │   ├── domain/
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart              # Interface
    │   │   └── usecases/
    │   │       ├── verify_code.dart                  # Use case: vérifier code
    │   │       └── verify_otp.dart                   # Use case: vérifier OTP
    │   │
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── auth_bloc.dart                    # Gestion états auth
    │       │   ├── auth_event.dart                   # LoginEvent, VerifyOtpEvent
    │       │   └── auth_state.dart                   # AuthInitial, Loading, Success, Error
    │       └── pages/
    │           ├── login_page.dart                   # Page connexion (terminal ID)
    │           └── otp_page.dart                     # Page OTP (6 chiffres)
    │
    ├── payments/                            # 💳 Paiements Stripe (Card + Link)
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── stripe_payment_intent_response.dart
    │   │   │   └── keyboard_model.dart
    │   │   └── repositories/
    │   │       └── stripe_payment_repository_impl.dart # 🆕 + idempotencyKey
    │   │
    │   ├── domain/
    │   │   ├── repositories/
    │   │   │   └── stripe_payment_repository.dart    # 🆕 Interface + idempotencyKey
    │   │   └── usescases/
    │   │       └── init_link_payment.dart            # 🆕 Use case + idempotencyKey
    │   │
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── stripe_payment_bloc.dart          # 🆕 Idempotence + protection double-clic
    │       │   ├── stripe_payment_event.dart         # ProcessStripePayment, InitLinkPayment
    │       │   └── stripe_payment_state.dart         # Loading, Success, Error, QrReady
    │       └── pages/
    │           ├── stripe_payment_page.dart          # 🛡️ Bouton désactivé si Loading
    │           ├── card_page.dart                    # Saisie manuelle carte
    │           ├── link_topay_page.dart              # QR code Link payment
    │           ├── insert_topay_page.dart            # Insertion carte physique
    │           ├── payment_page.dart                 # Page principale paiement
    │           ├── payment_methode_page.dart         # Choix méthode paiement
    │           └── payment_response_page.dart        # Résultat paiement
    │
    ├── mobile_payments/                     # 📱 Mobile Money (Orange, Wave)
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── mobile_payment_model.dart         # InitRequest, InitResponse, VerifyResponse
    │   │   └── repositories/
    │   │       └── mobile_payment_repository_impl.dart # 🆕 + idempotencyKey
    │   │
    │   ├── domain/
    │   │   ├── repositories/
    │   │   │   └── mobile_payment_repository.dart    # 🆕 Interface + idempotencyKey
    │   │   └── usecases/
    │   │       ├── init_payment.dart                 # 🆕 Use case + idempotencyKey
    │   │       ├── verify_payment.dart               # Vérification status
    │   │       └── stripe_verify_payment.dart        # Vérification Stripe
    │   │
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── mobile_payment_bloc.dart          # 🆕 Idempotence + protection double-clic
    │       │   ├── mobile_payment_event.dart         # InitPayment, VerifyPayment
    │       │   └── mobile_payment_state.dart         # Loading, Processing, QrReady, Success
    │       └── pages/
    │           ├── mobile_money_page.dart            # 🛡️ Bouton désactivé si Loading
    │           ├── mobile_money_amount_page.dart     # Saisie montant
    │           ├── mobile_money_contact_page.dart    # Saisie téléphone
    │           ├── om__payment_page.dart             # Page Orange Money
    │           └── scan_page.dart                    # Scan QR Wave
    │
    ├── nfc/                                 # 📡 NFC / Tap to Pay
    │   ├── scanner_reader.dart                       # Lecteur NFC Stripe Terminal
    │   ├── scanner_reader_old.dart
    │   └── stripe_taptopay_page.dart                 # Page Tap to Pay
    │
    ├── transactions/                        # 📊 Historique & Solde
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── transaction_remote_data_source.dart
    │   │   ├── models/
    │   │   │   ├── transaction_model.dart
    │   │   │   ├── balance_model.dart
    │   │   │   ├── gateway_model.dart
    │   │   │   ├── transactions_response_model.dart
    │   │   │   └── cancel_response.dart
    │   │   └── repositories/
    │   │       └── transaction_repository_impl.dart
    │   │
    │   ├── domain/
    │   │   ├── repositories/
    │   │   │   └── transaction_repository.dart
    │   │   └── usecases/
    │   │       ├── get_transactions.dart
    │   │       ├── get_balance.dart
    │   │       └── get_cancel_payment.dart
    │   │
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── transaction_bloc.dart
    │       │   ├── transaction_event.dart
    │       │   └── transaction_state.dart
    │       ├── pages/
    │       │   ├── home_page.dart                    # Dashboard transactions
    │       │   ├── payment_detail_page.dart          # Détail transaction
    │       │   └── search_page.dart                  # Recherche transactions
    │       └── widgets/
    │           ├── balance_card.dart
    │           ├── transaction_card.dart
    │           ├── ho_header.dart
    │           └── transactions_bottom_sheet.dart
    │
    ├── profil/                              # 👤 Profil utilisateur
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── profil_remote_data_source.dart
    │   │   ├── models/
    │   │   │   └── profil_model.dart
    │   │   └── repositories/
    │   │       └── profil_repository_impl.dart
    │   │
    │   ├── domain/
    │   │   ├── repositories/
    │   │   │   └── profil_repository.dart
    │   │   └── usecases/
    │   │       └── get_profil.dart
    │   │
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── profil_bloc.dart
    │       │   ├── profil_event.dart
    │       │   └── profil_state.dart
    │       └── pages/
    │           └── profil_page.dart
    │
    └── home/
        └── accueil_page.dart                        # Page d'accueil principale
```

---

## Flux de Données - Clean Architecture

### Exemple: Paiement Stripe avec Idempotence

```
┌──────────────────────────────────────────────────────────────────────────┐
│ 1. USER ACTION                                                            │
│    └─ Utilisateur clique sur "Payer"                                     │
└────────────────────────┬─────────────────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────────────────┐
│ 2. PRESENTATION LAYER                                                     │
│    stripe_payment_page.dart                                               │
│    └─ onTap: state is StripePaymentLoading ? null : processPayment()    │
│       🛡️ PROTECTION #1: UI désactivée si Loading                         │
└────────────────────────┬─────────────────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────────────────┐
│ 3. BLOC LAYER                                                             │
│    stripe_payment_bloc.dart                                               │
│    └─ ProcessStripePayment event received                                │
│       ├─ if (hasActiveTransaction('stripe_card_payment'))                │
│       │    └─ 🛡️ PROTECTION #2: Ignorer événement (return;)             │
│       │                                                                   │
│       ├─ emit(StripePaymentLoading())                                    │
│       │                                                                   │
│       ├─ idempotencyKey = generateKey('stripe_card_payment')             │
│       │    └─ 🔑 Clé UUID v4 générée et stockée                          │
│       │                                                                   │
│       └─ Appeler repository.createPaymentIntent(amount, key)             │
└────────────────────────┬─────────────────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────────────────┐
│ 4. DOMAIN LAYER                                                           │
│    stripe_payment_repository.dart (Interface)                             │
│    └─ createPaymentIntent(int amount, {String? idempotencyKey})          │
└────────────────────────┬─────────────────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────────────────┐
│ 5. DATA LAYER                                                             │
│    stripe_payment_repository_impl.dart                                    │
│    └─ createPaymentIntent(amount, idempotencyKey: key)                   │
│       └─ Appeler apiClient.post(endpoint, body, idempotencyKey: key)     │
└────────────────────────┬─────────────────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────────────────┐
│ 6. NETWORK LAYER                                                          │
│    api_client.dart                                                        │
│    └─ post(endpoint, body, idempotencyKey)                               │
│       ├─ if (idempotencyKey != null)                                     │
│       │    └─ headers['X-Idempotency-Key'] = idempotencyKey              │
│       │       🛡️ PROTECTION #3: Header envoyé au backend                 │
│       │                                                                   │
│       └─ HTTP POST vers backend                                          │
└────────────────────────┬─────────────────────────────────────────────────┘
                         │
                         ↓
                  ┌──────────────┐
                  │   BACKEND    │
                  │  API Server  │
                  └──────┬───────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────────────────┐
│ 7. RESPONSE HANDLING                                                      │
│    ├─ SUCCESS                                                             │
│    │   └─ clearKey('stripe_card_payment')  🧹 Clé supprimée              │
│    │   └─ emit(StripePaymentSuccess())                                   │
│    │                                                                      │
│    ├─ ERROR (Network/Timeout)                                            │
│    │   └─ ❌ Clé CONSERVÉE → Retry possible avec MÊME clé                │
│    │   └─ emit(StripePaymentError())                                     │
│    │                                                                      │
│    └─ ERROR (Business/Final)                                             │
│        └─ clearKey('stripe_card_payment')  🧹 Clé supprimée              │
│        └─ emit(StripePaymentError())                                     │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Gestion des Clés d'Idempotence

### IdempotencyKeyManager (Singleton)

```dart
┌─────────────────────────────────────────────────────────────────┐
│                  IdempotencyKeyManager                           │
├─────────────────────────────────────────────────────────────────┤
│ - _activeKeys: Map<String, String>                              │
│ - _uuidGenerator: Uuid()                                        │
├─────────────────────────────────────────────────────────────────┤
│ + generateKeyForTransaction(type): String                       │
│     └─ Génère UUID v4 → Stocke dans _activeKeys[type]           │
│                                                                  │
│ + getActiveKey(type): String?                                   │
│     └─ Retourne clé existante ou null                           │
│                                                                  │
│ + hasActiveTransaction(type): bool                              │
│     └─ Vérifie si transaction en cours (clé existe)             │
│                                                                  │
│ + clearKey(type): void                                          │
│     └─ Supprime clé après succès/échec                          │
│                                                                  │
│ + clearAllKeys(): void                                          │
│     └─ Nettoyage complet                                        │
└─────────────────────────────────────────────────────────────────┘
```

### Types de Transactions

| Type                      | Feature           | Description                |
|---------------------------|-------------------|----------------------------|
| `stripe_card_payment`     | payments          | Paiement carte Stripe      |
| `stripe_link_payment`     | payments          | Paiement Stripe Link (QR)  |
| `mobile_money_payment`    | mobile_payments   | Orange Money / Wave        |

---

## États BLoC & Protection UI

### StripePaymentState

```
StripePaymentInitial
    ↓
StripePaymentLoading  ← 🛡️ Bouton désactivé
    ↓
┌───┴────┐
│        │
↓        ↓
StripePaymentSuccess
LinkPaymentQrReady
         StripePaymentError
```

### MobilePaymentState

```
MobilePaymentInitial
    ↓
MobilePaymentLoading  ← 🛡️ Bouton désactivé
    ↓
┌───┴────┐
│        │
↓        ↓
MobilePaymentProcessing (avec countdown 180s)
MobilePaymentQrReady (Wave QR)
    ↓
MobilePaymentSuccess
MobilePaymentPending
MobilePaymentError
```

---

## Dépendances Clés

### Paiements
- `flutter_stripe: ^11.5.0` - SDK Stripe
- `mek_stripe_terminal: ^3.7.0` - Stripe Terminal (NFC)
- `uuid: ^4.5.1` - 🆕 Génération clés idempotence

### État & Navigation
- `flutter_bloc: ^8.1.3` - State management
- `equatable: ^2.0.5` - Comparaison états
- `dartz: ^0.10.1` - Either<Failure, Success>

### Réseau & Sécurité
- `dio: ^5.3.3` - Client HTTP
- `http: ^1.4.0` - HTTP client
- `flutter_secure_storage: ^9.0.0` - Stockage sécurisé
- `jwt_decode: ^0.3.1` - Décodage JWT

### UI
- `qr_flutter: ^4.1.0` - Génération QR codes
- `lottie: ^3.3.1` - Animations
- `shimmer: ^3.0.0` - Placeholders loading

---

## Endpoints API Backend

**Base URL**: `https://tyure-backend-dev.todoustudio.cloud/api/v1`

### Authentification
- `POST /merchants/terminals/request-otp` - Demander OTP
- `POST /merchants/terminals/verify-otp` - Vérifier OTP → JWT

### Paiements
- `POST /merchants/transactions/init-payment/card` - 🆕 Payment Intent (+ X-Idempotency-Key)
- `POST /merchants/transactions/init-payment/card/link` - 🆕 Link Payment (+ X-Idempotency-Key)
- `POST /merchants/transactions/init-payment/mobile-money` - 🆕 Mobile Money (+ X-Idempotency-Key)
- `GET /merchants/transactions/init-payment/mobile-money/check-status/{id}` - Vérifier statut

### Transactions
- `GET /auth/merchants/` - Balance + transactions

---

## Sécurité

### Token Management
```
┌──────────────┐
│ SecureStorage│  ← Stockage chiffré (flutter_secure_storage)
└──────┬───────┘
       │
       ↓
┌──────────────┐
│TokenValidator│  ← Validation JWT expiration
└──────┬───────┘
       │
       ↓ (si expiré)
┌──────────────┐
│  EventBus    │  ← TokenExpiredEvent → Logout automatique
└──────────────┘
```

### Idempotence (🆕)
- **Niveau 1**: UI désactivée pendant loading
- **Niveau 2**: BLoC ignore événements dupliqués
- **Niveau 3**: Header `X-Idempotency-Key` au backend

---

## Principes de Code

### Clean Architecture
✅ Séparation stricte des couches (Presentation / Domain / Data)
✅ Dépendances unidirectionnelles (vers l'intérieur)
✅ Repository Pattern avec interfaces

### SOLID
✅ **S**ingle Responsibility: Use cases avec une seule responsabilité
✅ **O**pen/Closed: Extensions via interfaces
✅ **L**iskov Substitution: Implementations respectent contrats
✅ **I**nterface Segregation: Interfaces spécifiques par feature
✅ **D**ependency Inversion: Dépendances sur abstractions

### DRY
✅ ApiClient centralisé
✅ Widgets réutilisables (core/widgets)
✅ Utils partagés (core/utils)

### Self-Documenting Code
✅ Noms explicites (ex: `IdempotencyKeyManager`, `hasActiveTransaction`)
✅ Pas de nombres magiques (constantes nommées)
✅ Code qui s'explique lui-même

---

## Diagramme de Séquence - Protection Double-Clic

```
User          UI          BLoC                IdempotencyManager    Repository    Backend
 │             │            │                          │                 │            │
 │─Click #1──→│            │                          │                 │            │
 │             │─Event────→│                          │                 │            │
 │             │            │─hasActive?──────────────→│                 │            │
 │             │            │←─false───────────────────│                 │            │
 │             │            │─generateKey──────────────→│                 │            │
 │             │            │←─uuid_abc────────────────│                 │            │
 │             │←Loading───│                          │                 │            │
 │             │  (disabled)│─createPayment(uuid_abc)─────────────────→│            │
 │             │            │                          │                 │─POST─────→│
 │             │            │                          │                 │  (header) │
 │─Click #2──→│ (ignored)  │                          │                 │            │
 │             │            │                          │                 │            │
 │─Click #3──→│ (ignored)  │                          │                 │            │
 │             │            │                          │                 │            │
 │             │            │                          │                 │←Response──│
 │             │            │←Success──────────────────────────────────│            │
 │             │            │─clearKey─────────────────→│                 │            │
 │             │←Success───│                          │                 │            │
 │             │  (enabled) │                          │                 │            │
```

---

## Notes Importantes

1. **Tous les paiements** passent par l'idempotence (Stripe + Mobile Money)
2. **Les clés sont conservées** en cas d'erreur réseau pour permettre le retry
3. **Les clés sont supprimées** après succès ou échec final
4. **Protection triple** contre les doublons (UI + BLoC + Backend)
5. **Pattern Singleton** pour IdempotencyKeyManager (instance unique)
6. **Event Bus** pour communication inter-modules (ex: TokenExpiredEvent)
7. **Secure Storage** pour tokens JWT chiffrés
