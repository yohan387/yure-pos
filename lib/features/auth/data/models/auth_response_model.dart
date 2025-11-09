import 'package:todouapp/features/auth/domain/entities/auth_response.dart';

class AuthResponseModel {
  final String message;
  final String accessToken;
  final String marchandId;
  final String terminalId;
  final String merchantFirstName;

  AuthResponseModel(
      {required this.message,
      required this.accessToken,
      required this.marchandId,
      required this.terminalId,
      this.merchantFirstName = ''});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'] ?? '',
      accessToken: json['access_token'] ?? '',
      marchandId: "${json['merchant_id']}",
      terminalId: "${json['terminal_id']}",
      merchantFirstName: "${json['merchant_first_name']}",
    );
  }

  AuthResponse toEntity() {
    return AuthResponse(
      message: message,
      accessToken: accessToken,
      marchandId: marchandId,
      terminalId: terminalId,
      merchantFirstName: merchantFirstName,
    );
  }
}
