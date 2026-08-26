class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'NetworkException(statusCode: $statusCode, message: $message)';
}

class ServerException extends NetworkException {
  const ServerException({
    required super.message,
    super.statusCode,
  });
}

class NoInternetException extends NetworkException {
  const NoInternetException({
    super.message = 'Internet aloqasi mavjud emas',
  });
}

class UnauthorizedException extends NetworkException {
  const UnauthorizedException({
    super.message = 'Avtorizatsiyadan oʻtilmagan',
    super.statusCode = 401,
  });
}
