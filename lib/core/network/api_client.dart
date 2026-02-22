import 'package:dio/dio.dart';
import '../config/env.dart';

class ApiClient {
  ApiClient._()
      : dio = Dio(BaseOptions(
          baseUrl: Env.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        ));

  final Dio dio;

  static final ApiClient I = ApiClient._();
}