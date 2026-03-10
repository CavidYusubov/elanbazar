import 'package:dio/dio.dart';
import '../config/env.dart';

class ApiClient {
  ApiClient._()
      : dio = Dio(
          BaseOptions(
            baseUrl: Env.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Accept': 'application/json',
            },
          ),
        );

  final Dio dio;

  static final ApiClient I = ApiClient._();

  void setToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
      return;
    }

    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}