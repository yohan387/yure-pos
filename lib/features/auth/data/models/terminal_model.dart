import 'package:todouapp/features/auth/domain/entities/terminal.dart';

class TerminalModel {
  final String id;
  final String name;
  final String code;
  final String status;

  TerminalModel({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
  });

  factory TerminalModel.fromJson(Map<String, dynamic> json) {
    return TerminalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'status': status,
    };
  }

  Terminal toEntity() {
    return Terminal(
      id: id,
      name: name,
      code: code,
      status: status,
    );
  }
}
