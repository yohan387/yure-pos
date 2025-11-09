class AuthResponse {
  final String message;
  final String accessToken;
  final String marchandId;
  final String terminalId;
  final String merchantFirstName;

  AuthResponse({
    required this.message,
    required this.accessToken,
    required this.marchandId,
    required this.terminalId,
    required this.merchantFirstName,
  });
}
