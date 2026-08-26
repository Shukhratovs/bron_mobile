import 'dart:convert';
import 'dart:io';
import 'network_exceptions.dart';

abstract class ApiClient {
  Future<dynamic> get(String url, {Map<String, String>? headers});
  Future<dynamic> post(String url, {Map<String, String>? headers, dynamic body});
  Future<dynamic> put(String url, {Map<String, String>? headers, dynamic body});
  Future<dynamic> delete(String url, {Map<String, String>? headers});
}

class StandardApiClient implements ApiClient {
  final HttpClient _httpClient;

  StandardApiClient({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  @override
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse(url);
      final request = await _httpClient.getUrl(uri);
      headers?.forEach((key, value) {
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
      request.headers.set('content-type', 'application/json; charset=utf-8');
      headers?.forEach((key, value) {
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
      request.headers.set('content-type', 'application/json; charset=utf-8');
      headers?.forEach((key, value) {
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
      headers?.forEach((key, value) {
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
    final dynamic decoded = responseBody.isNotEmpty ? jsonDecode(responseBody) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else if (response.statusCode == 401) {
      throw const UnauthorizedException();
    } else {
      throw ServerException(
        message: decoded is Map && decoded['message'] != null
            ? decoded['message'].toString()
            : 'Server xatoligi (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }
}
