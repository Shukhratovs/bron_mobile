import '../constants/app_strings.dart';

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
  // `super.message`ga const default berib bo'lmaydi — `AppStrings.tr()`
  // joriy tilga bog'liq va compile-time constant emas. Shuning uchun
  // konstruktor tanasida hisoblanadi (istisno chindan uloqtirilganda,
  // joriy til bilan).
  NoInternetException({String? message}) : super(message: message ?? AppStrings.noInternetTitle);
}

class UnauthorizedException extends NetworkException {
  const UnauthorizedException({
    super.message = 'Avtorizatsiyadan oʻtilmagan',
    super.statusCode = 401,
    super.code,
    super.body,
  });
}
