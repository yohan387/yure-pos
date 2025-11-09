import 'package:equatable/equatable.dart';

class Terminal extends Equatable {
  final String id;
  final String name;
  final String code;
  final String status;

  const Terminal({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, code, status];

  bool get isActive => status.toLowerCase() == 'active';
  bool get isInactive => status.toLowerCase() == 'inactive';
  bool get isPending => status.toLowerCase() == 'pending';
}
