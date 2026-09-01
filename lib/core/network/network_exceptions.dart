class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? body;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.code,
    this.body,
  });

  @override
  String toString() => 'NetworkException(statusCode: $statusCode, code: $code, message: $message)';
}

class ServerException extends NetworkException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.code,
    super.body,
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
    super.code,
    super.body,
  });
}
