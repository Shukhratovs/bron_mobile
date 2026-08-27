import 'dart:convert';
import 'dart:io';
import 'auth_local_storage.dart';
import 'network_exceptions.dart';

abstract class ApiClient {
  Future<dynamic> get(String url, {Map<String, String>? headers});
  Future<dynamic> post(String url, {Map<String, String>? headers, dynamic body});
  Future<dynamic> put(String url, {Map<String, String>? headers, dynamic body});
  Future<dynamic> patch(String url, {Map<String, String>? headers, dynamic body});
  Future<dynamic> delete(String url, {Map<String, String>? headers});
}

class StandardApiClient implements ApiClient {
  final HttpClient _httpClient;
  final AuthLocalStorage? authLocalStorage;

  StandardApiClient({
    HttpClient? httpClient,
    this.authLocalStorage,
  }) : _httpClient = httpClient ?? HttpClient();

  Future<Map<String, String>> _buildHeaders(Map<String, String>? customHeaders) async {
    final headers = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json; charset=utf-8',
    };

    if (authLocalStorage != null) {
      final token = await authLocalStorage!.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['authorization'] = 'Bearer $token';
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  @override
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _httpClient.getUrl(uri);
      final allHeaders = await _buildHeaders(headers);
      allHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
      final response = await request.close();
      return await _processResponse(response);
    } on SocketException {
      throw const NoInternetException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(message: e.toString());
    }
  }

  @override
  Future<dynamic> post(String url, {Map<String, String>? headers, dynamic body}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _httpClient.postUrl(uri);
      final allHeaders = await _buildHeaders(headers);
      allHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      return await _processResponse(response);
    } on SocketException {
      throw const NoInternetException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(message: e.toString());
    }
  }

  @override
  Future<dynamic> put(String url, {Map<String, String>? headers, dynamic body}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _httpClient.putUrl(uri);
      final allHeaders = await _buildHeaders(headers);
      allHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      return await _processResponse(response);
    } on SocketException {
      throw const NoInternetException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(message: e.toString());
    }
  }

  @override
  Future<dynamic> patch(String url, {Map<String, String>? headers, dynamic body}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _httpClient.patchUrl(uri);
      final allHeaders = await _buildHeaders(headers);
      allHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      return await _processResponse(response);
    } on SocketException {
      throw const NoInternetException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(message: e.toString());
    }
  }

  @override
  Future<dynamic> delete(String url, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _httpClient.deleteUrl(uri);
      final allHeaders = await _buildHeaders(headers);
      allHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
      final response = await request.close();
      return await _processResponse(response);
    } on SocketException {
      throw const NoInternetException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(message: e.toString());
    }
  }

  Future<dynamic> _processResponse(HttpClientResponse response) async {
    final responseBody = await response.transform(utf8.decoder).join();
    dynamic decoded;
    if (responseBody.isNotEmpty) {
      try {
        decoded = jsonDecode(responseBody);
      } catch (_) {
        decoded = responseBody;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else if (response.statusCode == 401) {
      if (authLocalStorage != null) {
        await authLocalStorage!.clear();
      }
      final message = _extractErrorMessage(decoded) ?? 'Tizimga qaytadan kiring';
      throw UnauthorizedException(message: message);
    } else if (response.statusCode == 422) {
      final message = _extractValidationErrorMessage(decoded) ?? 'Ma\'lumotlar to\'g\'ri kiritilmadi';
      throw ServerException(message: message, statusCode: 422);
    } else {
      final message = _extractErrorMessage(decoded) ?? 'Server xatoligi (${response.statusCode})';
      throw ServerException(
        message: message,
        statusCode: response.statusCode,
      );
    }
  }

  String? _extractErrorMessage(dynamic decoded) {
    if (decoded is Map) {
      if (decoded['detail'] != null) {
        if (decoded['detail'] is String) return decoded['detail'].toString();
        if (decoded['detail'] is List) return _extractValidationErrorMessage(decoded);
      }
      if (decoded['message'] != null) return decoded['message'].toString();
      if (decoded['error'] != null) return decoded['error'].toString();
    }
    return null;
  }

  String? _extractValidationErrorMessage(dynamic decoded) {
    if (decoded is Map && decoded['detail'] is List) {
      final list = decoded['detail'] as List;
      final messages = <String>[];
      for (final item in list) {
        if (item is Map && item['msg'] != null) {
          final loc = item['loc'] is List ? (item['loc'] as List).join('.') : '';
          messages.add('$loc: ${item['msg']}');
        }
      }
      if (messages.isNotEmpty) return messages.join('\n');
    }
    return null;
  }
}
