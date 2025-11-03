/// Données mockées centralisées pour le mode mock
/// Utilisées par tous les MockDataSources
class MockData {
  // ========== AUTH ==========

  /// Token JWT mocké avec expiration lointaine
  static const mockToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlRlcm1pbmFsIE1vY2siLCJpYXQiOjE1MTYyMzkwMjIsImV4cCI6OTk5OTk5OTk5OX0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

  // ========== PROFIL ==========

  /// Données du profil mocké
  static final mockProfil = {
    "id": "terminal_mock_001",
    "terminal_code": "MOCK-POS-ABC123",
    "merchant_name": "Boutique Todou Test",
    "email": "test@todou.com",
    "phone": "+221701234567",
    "balance": 1250000.0,
    "currency": "XOF",
    "status": "active",
    "created_at": "2025-01-01T00:00:00Z",
  };

  // ========== BALANCE ==========

  /// Données de balance mockée
  static final mockBalance = {
    "current_balance": 1250000.0,
    "available_balance": 1200000.0,
    "pending_balance": 50000.0,
    "currency": "XOF",
    "last_updated": DateTime.now().toIso8601String(),
  };

  // ========== TRANSACTIONS ==========

  /// Liste de transactions mockées
  static final mockTransactions = [
    {
      "id": "txn_mock_001",
      "amount": 25000.0,
      "currency": "XOF",
      "status": "success",
      "payment_method": "orange_money",
      "customer_phone": "+221701234567",
      "description": "Paiement Orange Money",
      "created_at": "2025-10-31T14:30:00Z",
    },
    {
      "id": "txn_mock_002",
      "amount": 50000.0,
      "currency": "XOF",
      "status": "success",
      "payment_method": "card",
      "card_brand": "visa",
      "card_last4": "4242",
      "description": "Paiement par carte",
      "created_at": "2025-10-31T12:15:00Z",
    },
    {
      "id": "txn_mock_003",
      "amount": 15000.0,
      "currency": "XOF",
      "status": "failed",
      "payment_method": "wave",
      "error_message": "Solde insuffisant",
      "description": "Paiement Wave échoué",
      "created_at": "2025-10-31T10:00:00Z",
    },
    {
      "id": "txn_mock_004",
      "amount": 75000.0,
      "currency": "XOF",
      "status": "pending",
      "payment_method": "orange_money",
      "customer_phone": "+221709876543",
      "description": "Paiement en attente",
      "created_at": "2025-10-31T09:00:00Z",
    },
  ];

  // ========== MOBILE PAYMENTS (Orange Money, Wave) ==========

  /// Réponse mockée pour l'initialisation d'un paiement mobile
  static Map<String, dynamic> mockMobilePaymentInit({
    required double amount,
    required String paymentMethod,
    required String customerPhone,
  }) {
    final transactionId = "mock_txn_${DateTime.now().millisecondsSinceEpoch}";

    return {
      "transaction_id": transactionId,
      "status": "pending",
      "amount": amount,
      "currency": "XOF",
      "payment_method": paymentMethod,
      "customer_phone": customerPhone,
      "payment_url": "https://mock-payment-url.com/$transactionId",
      if (paymentMethod == "wave")
        "qr_code": "WAVE_QR_CODE_DATA_$transactionId",
      "expires_at": DateTime.now().add(Duration(minutes: 30)).toIso8601String(),
    };
  }

  /// Réponse mockée pour la vérification d'un paiement mobile
  static Map<String, dynamic> mockMobilePaymentVerification({
    required String transactionId,
    bool success = true,
  }) {
    return {
      "transaction_id": transactionId,
      "status": success ? "success" : "failed",
      "amount": 25000.0,
      "currency": "XOF",
      "payment_method": "orange_money",
      "customer_phone": "+221701234567",
      if (!success) "error_message": "Paiement annulé par l'utilisateur",
      "verified_at": DateTime.now().toIso8601String(),
    };
  }

  // ========== STRIPE PAYMENTS ==========

  /// Réponse mockée pour la création d'un Payment Intent
  static Map<String, dynamic> mockStripePaymentIntent(double amount) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return {
      "client_secret": "pi_mock_secret_$timestamp",
      "payment_intent_id": "pi_mock_$timestamp",
      "amount": amount,
      "currency": "xof",
      "status": "requires_payment_method",
    };
  }

  /// Réponse mockée pour la création d'un Link Payment (QR code Stripe)
  static Map<String, dynamic> mockStripeLinkPayment(double amount) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return {
      "payment_link": "https://checkout.stripe.com/mock-link-$timestamp",
      "qr_code_data": "STRIPE_QR_MOCK_DATA_$timestamp",
      "amount": amount,
      "currency": "xof",
      "expires_at": DateTime.now().add(Duration(hours: 1)).toIso8601String(),
    };
  }

  // ========== NFC / TAP TO PAY ==========

  /// Réponse mockée pour la découverte de lecteurs NFC
  static final mockNfcReaders = [
    {
      "id": "reader_mock_001",
      "name": "Stripe Reader M2",
      "serial_number": "MOCK-M2-123456",
      "device_type": "chipper_2x",
      "status": "online",
    },
  ];

  /// Réponse mockée pour la lecture NFC
  static Map<String, dynamic> mockNfcPayment(double amount) {
    return {
      "transaction_id": "nfc_mock_${DateTime.now().millisecondsSinceEpoch}",
      "status": "success",
      "amount": amount,
      "currency": "XOF",
      "payment_method": "nfc",
      "card_brand": "visa",
      "card_last4": "1234",
      "processed_at": DateTime.now().toIso8601String(),
    };
  }
}
