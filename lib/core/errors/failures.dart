import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(
            message:
                'Pas de connexion internet. Veuillez vérifier votre connexion et réessayer.');
}

class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure()
      : super(message: 'Your session has expired. Please log in again.');
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}
