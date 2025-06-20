class AuthResponseModel {
  final String message;
  final String accessToken;
  final String marchandId;
  final String terminalId;

  AuthResponseModel(
      {required this.message,
      required this.accessToken,
      required this.marchandId,
      required this.terminalId});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'] ?? '',
      accessToken: json['access_token'] ?? '',
      marchandId: "${json['merchant_id']}",
      terminalId: "${json['terminal_id']}",
    );
  }
}
