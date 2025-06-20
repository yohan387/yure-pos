class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => '$message';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException({this.message = 'Token has expired'});

  @override
  String toString() => 'TokenExpiredException: $message';
}
