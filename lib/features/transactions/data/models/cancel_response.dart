class CancelPaymentResponse {
  final String message;

  CancelPaymentResponse({
    required this.message,
  });

  factory CancelPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CancelPaymentResponse(
      message: json['message'] ?? 'Transaction cancelled successfully',
    );
  }
}
