import '../../features/transactions/data/models/gateway_model.dart';

List<GatewayModel> gatewayList = [
  GatewayModel(
    imageUrl: 'assets/images/wave.png',
    name: 'Wave',
  ),
  GatewayModel(
    imageUrl: 'assets/images/orange.png',
    name: 'Orange',
  ),
  GatewayModel(
    imageUrl: 'assets/images/momo.png',
    name: 'MTN',
  ),
  GatewayModel(
    imageUrl: 'assets/images/moov.png',
    name: 'Moov',
  ),
];

var transactions = {
  "status": true,
  "message": "Transactions retrieved successfully",
  "current_page": 1,
  "per_page": 5,
  "total": 22,
  "last_page": 5,
  "data": [
    {
      "id": 8,
      "amount": 5000,
      "currency": "XOF",
      "created_at": null,
      "status": "pending",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_354552zayr5e2g5e5fe",
      "payment_method": "Mobile Money",
      "customer_phone": "0554426090",
      "network": "Orange"
    },
    {
      "id": 5,
      "amount": 4000,
      "currency": "XOF",
      "created_at": null,
      "status": "succeeded",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_354552zayg5e5fe",
      "payment_method": "Card",
      "customer_phone": "0554426090",
      "network": "Visa"
    },
    {
      "id": 9,
      "amount": 2500,
      "currency": "XOF",
      "created_at": null,
      "status": "failed",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_trx_009",
      "payment_method": "Mobile Money",
      "customer_phone": "0700000001",
      "network": "MTN"
    },
    {
      "id": 10,
      "amount": 8000,
      "currency": "XOF",
      "created_at": null,
      "status": "succeeded",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_trx_010",
      "payment_method": "Card",
      "customer_phone": "0700000002",
      "network": "Mastercard"
    },
    {
      "id": 11,
      "amount": 3000,
      "currency": "XOF",
      "created_at": null,
      "status": "pending",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_trx_011",
      "payment_method": "Mobile Money",
      "customer_phone": "0700000003",
      "network": "Moov"
    },
    {
      "id": 11,
      "amount": 5000,
      "currency": "XOF",
      "created_at": null,
      "status": "succeeded",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_trx_0112144",
      "payment_method": "Mobile Money",
      "customer_phone": "0700000003",
      "network": "Wave"
    },
    {
      "id": 8,
      "amount": 5000,
      "currency": "XOF",
      "created_at": null,
      "status": "pending",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_354552zayr5e2g5e5fe",
      "payment_method": "Mobile Money",
      "customer_phone": "0554426090",
      "network": "Orange"
    },
    {
      "id": 5,
      "amount": 4000,
      "currency": "XOF",
      "created_at": null,
      "status": "succeeded",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_354552zayg5e5fe",
      "payment_method": "Card",
      "customer_phone": "0554426090",
      "network": "Visa"
    },
    {
      "id": 9,
      "amount": 2500,
      "currency": "XOF",
      "created_at": null,
      "status": "failed",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_trx_009",
      "payment_method": "Mobile Money",
      "customer_phone": "0700000001",
      "network": "MTN"
    },
    {
      "id": 11,
      "amount": 3000,
      "currency": "XOF",
      "created_at": null,
      "status": "pending",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_trx_011",
      "payment_method": "Mobile Money",
      "customer_phone": "0700000003",
      "network": "Moov"
    },
    {
      "id": 11,
      "amount": 3000,
      "currency": "XOF",
      "created_at": null,
      "status": "pending",
      "merchant_id": 8,
      "terminal_id": 15,
      "transaction_ref": "i_trx_011",
      "payment_method": "Mobile Money",
      "customer_phone": "0700000003",
      "network": "Moov"
    },
  ]
};
