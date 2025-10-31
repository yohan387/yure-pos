# Architecture Diagrams - Todou POS App

Ce fichier contient tous les diagrammes de l'architecture en format **Mermaid**.

> 💡 **Visualisation** : Ces diagrammes s'affichent automatiquement sur GitHub, GitLab, ou avec l'extension VS Code "Markdown Preview Mermaid Support"

---

## 1. Vue d'ensemble - Clean Architecture par Couches

```mermaid
graph TB
    subgraph Presentation["🖥️ PRESENTATION LAYER"]
        UI[Pages/Widgets]
        BLoC[BLoCs]
        Events[Events/States]
        UI -->|user actions| BLoC
        BLoC -->|emit states| Events
    end

    subgraph Domain["🧠 DOMAIN LAYER"]
        UseCases[Use Cases]
        RepoInterface[Repository Interfaces]
        UseCases -->|uses| RepoInterface
    end

    subgraph Data["💾 DATA LAYER"]
        RepoImpl[Repository Implementations]
        DataSources[Data Sources]
        Models[Models]
        RepoImpl -->|calls| DataSources
        DataSources -->|uses| Models
    end

    subgraph Core["⚙️ CORE LAYER"]
        Network[Network/API Client]
        Utils[Utils/Helpers]
        Widgets[Shared Widgets]
    end

    Presentation -->|calls| Domain
    Domain -->|implements| Data
    Data -->|uses| Core

    style Presentation fill:#e3f2fd
    style Domain fill:#f3e5f5
    style Data fill:#e8f5e9
    style Core fill:#fff3e0
```

---

## 2. Architecture par Features

```mermaid
graph LR
    subgraph Features["📦 FEATURES"]
        Auth[🔐 Auth<br/>OTP Login]
        Payments[💳 Payments<br/>Stripe Card/Link]
        Mobile[📱 Mobile Payments<br/>Orange/Wave]
        NFC[📡 NFC<br/>Tap to Pay]
        Trans[📊 Transactions<br/>History/Balance]
        Profil[👤 Profil<br/>User Info]
    end

    subgraph Core2["⚙️ CORE - Shared"]
        ApiClient[API Client<br/>+ Idempotency]
        IdempMgr[Idempotency<br/>Key Manager]
        SecStore[Secure Storage<br/>JWT Tokens]
        TokenVal[Token Validator]
        EventBus[Event Bus]
    end

    Auth --> Core2
    Payments --> Core2
    Mobile --> Core2
    NFC --> Core2
    Trans --> Core2
    Profil --> Core2

    ApiClient -.uses.-> IdempMgr
    ApiClient -.uses.-> SecStore
    TokenVal -.validates.-> SecStore
    TokenVal -.fires.-> EventBus

    style Auth fill:#ffcdd2
    style Payments fill:#c5e1a5
    style Mobile fill:#b3e5fc
    style NFC fill:#ffe0b2
    style Trans fill:#d1c4e9
    style Profil fill:#f8bbd0
    style Core2 fill:#fff9c4
```

---

## 3. Flux Complet - Paiement Stripe avec Idempotence

```mermaid
sequenceDiagram
    actor User
    participant UI as 🖥️ UI Page
    participant BLoC as 🧠 Stripe BLoC
    participant IdempMgr as 🔑 Idempotency<br/>Manager
    participant UseCase as Use Case
    participant Repo as Repository
    participant API as 🌐 API Client
    participant Backend as ☁️ Backend

    User->>UI: Click "Payer"

    rect rgb(255, 200, 200)
        Note over UI: 🛡️ Protection #1: UI
        UI->>UI: Check: state is Loading?
        alt Is Loading
            UI-->>User: Button disabled ❌
        end
    end

    UI->>BLoC: ProcessStripePayment event

    rect rgb(200, 255, 200)
        Note over BLoC,IdempMgr: 🛡️ Protection #2: BLoC
        BLoC->>IdempMgr: hasActiveTransaction("stripe_card_payment")?
        IdempMgr-->>BLoC: false

        BLoC->>BLoC: emit(StripePaymentLoading)
        BLoC->>UI: Update state
        UI->>UI: Disable button

        BLoC->>IdempMgr: generateKey("stripe_card_payment")
        IdempMgr-->>BLoC: uuid: "abc-123-def-456"
    end

    User->>UI: Click #2 (rapid)
    UI-->>User: Ignored (disabled) ❌

    User->>UI: Click #3 (rapid)
    UI-->>User: Ignored (disabled) ❌

    BLoC->>UseCase: createPaymentIntent(amount, key)
    UseCase->>Repo: createPaymentIntent(amount, key)
    Repo->>API: post(endpoint, body, idempotencyKey)

    rect rgb(200, 200, 255)
        Note over API,Backend: 🛡️ Protection #3: Backend
        API->>API: Add header:<br/>X-Idempotency-Key: abc-123-def-456
        API->>Backend: HTTP POST /init-payment/card
    end

    Backend-->>API: 200 OK + PaymentIntent
    API-->>Repo: Response
    Repo-->>UseCase: Either.Right(PaymentIntent)
    UseCase-->>BLoC: Success

    BLoC->>IdempMgr: clearKey("stripe_card_payment")
    IdempMgr-->>BLoC: ✅ Key deleted

    BLoC->>BLoC: emit(StripePaymentSuccess)
    BLoC->>UI: Update state
    UI->>UI: Enable button
    UI-->>User: ✅ Payment Success
```

---

## 4. Gestion des Clés d'Idempotence

```mermaid
classDiagram
    class IdempotencyKeyManager {
        -Map~String,String~ _activeKeys
        -Uuid _uuidGenerator
        +generateKeyForTransaction(type) String
        +getActiveKey(type) String?
        +hasActiveTransaction(type) bool
        +clearKey(type) void
        +clearAllKeys() void
    }

    class StripePaymentBloc {
        -IdempotencyKeyManager _idempotencyManager
        +stripeCardPaymentType = "stripe_card_payment"
        +stripeLinkPaymentType = "stripe_link_payment"
        +_onProcessPayment()
        +_onInitLinkPayment()
    }

    class MobilePaymentBloc {
        -IdempotencyKeyManager _idempotencyManager
        +mobileMoneyPaymentType = "mobile_money_payment"
        +_onInitPayment()
        +_onVerifyPayment()
    }

    StripePaymentBloc --> IdempotencyKeyManager : uses
    MobilePaymentBloc --> IdempotencyKeyManager : uses

    note for IdempotencyKeyManager "Singleton Pattern\nUne seule instance globale"
```

---

## 5. États BLoC - Stripe Payment

```mermaid
stateDiagram-v2
    [*] --> StripePaymentInitial

    StripePaymentInitial --> StripePaymentLoading : ProcessStripePayment event

    note right of StripePaymentLoading
        🛡️ UI Button disabled
        🔑 Idempotency key generated
    end note

    StripePaymentLoading --> StripePaymentSuccess : Payment completed
    StripePaymentLoading --> StripePaymentError : Payment failed
    StripePaymentLoading --> LinkPaymentQrReady : QR generated (Link)

    note right of StripePaymentSuccess
        🧹 Key cleared
        ✅ Button re-enabled
    end note

    note right of StripePaymentError
        🧹 Key cleared
        ❌ Button re-enabled
    end note

    StripePaymentSuccess --> [*]
    StripePaymentError --> StripePaymentInitial : Retry possible
    LinkPaymentQrReady --> [*]
```

---

## 6. États BLoC - Mobile Payment

```mermaid
stateDiagram-v2
    [*] --> MobilePaymentInitial

    MobilePaymentInitial --> MobilePaymentLoading : InitPayment event

    note right of MobilePaymentLoading
        🛡️ UI Button disabled
        🔑 Idempotency key generated
    end note

    MobilePaymentLoading --> MobilePaymentProcessing : Orange Money (OTP sent)
    MobilePaymentLoading --> MobilePaymentQrReady : Wave (QR generated)
    MobilePaymentLoading --> MobilePaymentError : Init failed

    MobilePaymentProcessing --> MobilePaymentSuccess : Verified (180s polling)
    MobilePaymentProcessing --> MobilePaymentError : Timeout/Failed

    MobilePaymentQrReady --> MobilePaymentSuccess : User scanned & paid
    MobilePaymentQrReady --> MobilePaymentError : Timeout (180s)

    note right of MobilePaymentSuccess
        🧹 Key cleared
        ✅ Transaction complete
    end note

    note right of MobilePaymentError
        🧹 Key cleared
        ❌ Can retry
    end note

    MobilePaymentSuccess --> [*]
    MobilePaymentError --> MobilePaymentInitial : Retry
```

---

## 7. Architecture Réseau - API Client

```mermaid
graph TB
    subgraph BLoCs["BLoCs Layer"]
        StripeBLoC[Stripe Payment BLoC]
        MobileBLoC[Mobile Payment BLoC]
    end

    subgraph Repositories["Repository Layer"]
        StripeRepo[Stripe Repository]
        MobileRepo[Mobile Repository]
    end

    subgraph Network["Network Layer"]
        ApiClient[API Client]
        IdempMgr2[Idempotency Manager]
    end

    subgraph Backend2["Backend API"]
        AuthEndpoint[/merchants/terminals/verify-otp]
        StripeEndpoint[/transactions/init-payment/card]
        MobileEndpoint[/transactions/init-payment/mobile-money]
    end

    StripeBLoC -->|idempotencyKey| StripeRepo
    MobileBLoC -->|idempotencyKey| MobileRepo

    StripeRepo -->|post with key| ApiClient
    MobileRepo -->|post with key| ApiClient

    ApiClient -->|reads/writes| IdempMgr2
    ApiClient -->|X-Idempotency-Key header| StripeEndpoint
    ApiClient -->|X-Idempotency-Key header| MobileEndpoint
    ApiClient -->|no key needed| AuthEndpoint

    style IdempMgr2 fill:#fff59d
    style ApiClient fill:#90caf9
```

---

## 8. Flux de Sécurité - Token Management

```mermaid
sequenceDiagram
    participant App
    participant SecStorage as 🔐 Secure Storage
    participant TokenVal as ✅ Token Validator
    participant EventBus as 📡 Event Bus
    participant ApiClient as API Client
    participant Backend as Backend

    App->>SecStorage: App starts
    SecStorage-->>App: Get stored token

    alt Token exists
        App->>TokenVal: Validate token
        TokenVal->>TokenVal: Check JWT expiration

        alt Token valid
            TokenVal-->>App: ✅ Valid
            App->>App: Navigate to Home
        else Token expired
            TokenVal->>EventBus: Fire TokenExpiredEvent
            EventBus->>App: Receive event
            App->>SecStorage: Delete token
            App->>App: Navigate to Login
        end
    else No token
        App->>App: Navigate to Login
    end

    rect rgb(255, 230, 230)
        Note over App,Backend: During API calls
        App->>ApiClient: Make request
        ApiClient->>SecStorage: Get token
        ApiClient->>TokenVal: Validate token

        alt Token valid
            ApiClient->>Backend: Request with Authorization header
            Backend-->>ApiClient: Response
        else Token expired
            TokenVal->>EventBus: Fire TokenExpiredEvent
            EventBus->>App: Auto logout
        end
    end
```

---

## 9. Feature Auth - Architecture Détaillée

```mermaid
graph TB
    subgraph Presentation["Presentation Layer"]
        LoginPage[Login Page<br/>Enter Terminal ID]
        OtpPage[OTP Page<br/>Enter 6 digits]
        AuthBLoC[Auth BLoC]
    end

    subgraph Domain["Domain Layer"]
        VerifyCode[Use Case:<br/>VerifyCode]
        VerifyOtp[Use Case:<br/>VerifyOtp]
        AuthRepoInterface[Auth Repository<br/>Interface]
    end

    subgraph Data["Data Layer"]
        AuthRepoImpl[Auth Repository<br/>Implementation]
        AuthDataSource[Auth Remote<br/>Data Source]
        AuthModel[Auth Response<br/>Model]
    end

    LoginPage -->|RequestOtpEvent| AuthBLoC
    OtpPage -->|VerifyOtpEvent| AuthBLoC

    AuthBLoC -->|call| VerifyCode
    AuthBLoC -->|call| VerifyOtp

    VerifyCode -->|uses| AuthRepoInterface
    VerifyOtp -->|uses| AuthRepoInterface

    AuthRepoInterface -.implemented by.-> AuthRepoImpl

    AuthRepoImpl -->|calls| AuthDataSource
    AuthDataSource -->|POST /request-otp| Backend[Backend API]
    AuthDataSource -->|POST /verify-otp| Backend
    AuthDataSource -->|parses| AuthModel

    AuthModel -->|JWT Token| SecStorage[Secure Storage]

    style LoginPage fill:#ffccbc
    style OtpPage fill:#ffccbc
    style AuthBLoC fill:#90caf9
    style Backend fill:#c5e1a5
```

---

## 10. Feature Payments - Architecture Détaillée

```mermaid
graph TB
    subgraph Presentation2["Presentation Layer"]
        StripePayPage[Stripe Payment Page]
        CardPage[Card Page]
        LinkPage[Link Payment Page]
        StripeBLoC2[Stripe Payment BLoC<br/>+ Idempotency Protection]
    end

    subgraph Domain2["Domain Layer"]
        InitLinkPayment[Use Case:<br/>InitLinkPayment]
        StripeRepoInterface[Stripe Repository<br/>Interface]
    end

    subgraph Data2["Data Layer"]
        StripeRepoImpl2[Stripe Repository Impl<br/>+ idempotencyKey param]
        StripeModel[Payment Intent<br/>Response Model]
    end

    subgraph Core3["Core Layer"]
        IdempMgr3[🔑 Idempotency Manager]
        ApiClient2[API Client<br/>+ X-Idempotency-Key header]
    end

    StripePayPage -->|ProcessStripePayment| StripeBLoC2
    CardPage -->|ProcessStripePayment| StripeBLoC2
    LinkPage -->|InitLinkPayment| StripeBLoC2

    StripeBLoC2 -->|generate key| IdempMgr3
    StripeBLoC2 -->|check active| IdempMgr3
    StripeBLoC2 -->|call with key| InitLinkPayment

    InitLinkPayment -->|uses| StripeRepoInterface
    StripeRepoInterface -.implemented by.-> StripeRepoImpl2

    StripeRepoImpl2 -->|post with key| ApiClient2
    ApiClient2 -->|POST + header| Backend2[Backend API]
    Backend2 -->|response| StripeModel

    StripeBLoC2 -->|on success/error| IdempMgr3
    Note right of IdempMgr3: clearKey() after<br/>success or final error

    style StripeBLoC2 fill:#fff59d
    style IdempMgr3 fill:#ffccbc
    style ApiClient2 fill:#90caf9
```

---

## 11. Triple Protection contre les Doublons

```mermaid
graph TD
    User[👤 User Click] --> Check1{🛡️ Protection #1<br/>UI Layer}

    Check1 -->|Button enabled| Event[Send Event to BLoC]
    Check1 -->|Button disabled| Ignore1[❌ Ignore Click]

    Event --> Check2{🛡️ Protection #2<br/>BLoC Layer}

    Check2 -->|No active transaction| GenKey[Generate UUID Key]
    Check2 -->|Transaction in progress| Ignore2[❌ Ignore Event]

    GenKey --> DisableUI[Emit Loading State<br/>→ Disable UI]
    DisableUI --> SendReq[Send Request to Backend]

    SendReq --> Check3{🛡️ Protection #3<br/>Backend Layer}

    Check3 -->|First request with key| Process[Process Payment]
    Check3 -->|Duplicate key detected| ReturnCached[Return Cached Result]

    Process --> Success[Payment Success]
    ReturnCached --> Success

    Success --> ClearKey[Clear Idempotency Key]
    ClearKey --> EnableUI[Emit Success State<br/>→ Enable UI]

    style Check1 fill:#ffccbc
    style Check2 fill:#c5e1a5
    style Check3 fill:#90caf9
    style Ignore1 fill:#ef5350
    style Ignore2 fill:#ef5350
```

---

## 12. Types de Transactions & Clés

```mermaid
graph LR
    subgraph TransactionTypes["📋 Transaction Types"]
        Type1[stripe_card_payment]
        Type2[stripe_link_payment]
        Type3[mobile_money_payment]
    end

    subgraph IdempKeys["🔑 Idempotency Keys"]
        Key1[uuid-card-abc-123]
        Key2[uuid-link-def-456]
        Key3[uuid-mobile-ghi-789]
    end

    subgraph Features2["Features"]
        StripeCard[Stripe Card<br/>Payment]
        StripeLink[Stripe Link<br/>QR Payment]
        MobileMoney[Mobile Money<br/>Orange/Wave]
    end

    StripeCard -->|generates| Type1
    StripeLink -->|generates| Type2
    MobileMoney -->|generates| Type3

    Type1 -.maps to.-> Key1
    Type2 -.maps to.-> Key2
    Type3 -.maps to.-> Key3

    Key1 -->|sent in header| Backend3[Backend API]
    Key2 -->|sent in header| Backend3
    Key3 -->|sent in header| Backend3

    style Type1 fill:#ffccbc
    style Type2 fill:#c5e1a5
    style Type3 fill:#90caf9
```

---

## 13. Lifecycle d'une Clé d'Idempotence

```mermaid
stateDiagram-v2
    [*] --> NoKey : Initial State

    NoKey --> KeyGenerated : User initiates payment

    note right of KeyGenerated
        UUID v4 generated
        Stored in memory
        Transaction type as key
    end note

    KeyGenerated --> KeyActive : Request sent to backend

    note right of KeyActive
        Header: X-Idempotency-Key
        Key preserved in memory
        Duplicate events ignored
    end note

    KeyActive --> KeyRetained : Network Error
    KeyActive --> KeyCleared : Success Response
    KeyActive --> KeyCleared : Final Error Response

    note right of KeyRetained
        Same key reused on retry
        Ensures same transaction
    end note

    note right of KeyCleared
        Key deleted from memory
        Ready for new transaction
    end note

    KeyRetained --> KeyActive : User retries
    KeyCleared --> NoKey

    NoKey --> [*]
```

---

## 14. Diagramme de Déploiement

```mermaid
graph TB
    subgraph Mobile["📱 Mobile Device"]
        FlutterApp[Flutter App<br/>Todou POS]
        SecStorage2[Secure Storage<br/>Encrypted]
        FlutterApp -.stores tokens.-> SecStorage2
    end

    subgraph Cloud["☁️ Cloud Infrastructure"]
        Backend4[Backend API Server<br/>tyure-backend-dev.todoustudio.cloud]
        Database[(Database)]
        Backend4 -.reads/writes.-> Database
    end

    subgraph External["🌐 External Services"]
        StripeAPI[Stripe API]
        OrangeAPI[Orange Money API]
        WaveAPI[Wave API]
    end

    FlutterApp -->|HTTPS + JWT| Backend4
    FlutterApp -->|X-Idempotency-Key header| Backend4

    Backend4 -->|Process card payments| StripeAPI
    Backend4 -->|Process Orange Money| OrangeAPI
    Backend4 -->|Process Wave| WaveAPI

    style FlutterApp fill:#90caf9
    style Backend4 fill:#c5e1a5
    style StripeAPI fill:#ffccbc
    style OrangeAPI fill:#fff59d
    style WaveAPI fill:#ce93d8
```

---

## 15. Patterns & Principes Appliqués

```mermaid
mindmap
  root((Clean Architecture<br/>Todou POS))
    Patterns
      Singleton
        IdempotencyKeyManager
      Repository
        Interfaces in Domain
        Implementations in Data
      BLoC
        State Management
        Event driven
      Either
        Failure or Success
        Error handling
    SOLID
      Single Responsibility
        Use Cases
        One job per class
      Open/Closed
        Extension via interfaces
      Liskov Substitution
        Implementations respect contracts
      Interface Segregation
        Specific interfaces per feature
      Dependency Inversion
        Depend on abstractions
    DRY
      ApiClient centralized
      Reusable widgets
      Shared utils
    Security
      JWT Tokens
        Secure storage
        Auto expiration
      Idempotency
        UUID v4 keys
        Triple protection
      Token Validation
        Before each request
```

---

## Instructions d'utilisation

### Visualiser les diagrammes

1. **Sur GitHub/GitLab** : Les diagrammes s'affichent automatiquement
2. **VS Code** : Installer l'extension "Markdown Preview Mermaid Support"
3. **En ligne** : https://mermaid.live (copier/coller le code)

### Exporter en images

```bash
# Installation de mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# Exporter un diagramme en PNG
mmdc -i ARCHITECTURE_DIAGRAMS.md -o diagram.png
```

### Modifier les diagrammes

La syntaxe Mermaid est simple :
- `graph TB` : Graphe vertical
- `sequenceDiagram` : Diagramme de séquence
- `stateDiagram-v2` : Diagramme d'états
- `classDiagram` : Diagramme de classes
- `mindmap` : Carte mentale

Documentation complète : https://mermaid.js.org/
