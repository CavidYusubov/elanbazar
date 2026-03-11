import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/ad_create_attribute.dart';
import '../models/ad_create_category.dart';
import '../models/ad_create_meta.dart';
import '../models/ad_create_request.dart';
import '../models/ad_create_response.dart';

class AdCreateRepo {
  final Dio _dio = ApiClient.I.dio;

  Future<AdCreateMeta> fetchCreateMeta() async {
    final res = await _dio.get('/account/ads/create-meta');
    return AdCreateMeta.fromJson(_asMap(res.data));
  }

  Future<List<AdCreateCategory>> fetchRootCategories() async {
    final res = await _dio.get('/categories/tree');
    return _parseItems<AdCreateCategory>(
      res.data,
      (json) => AdCreateCategory.fromJson(json),
    );
  }

  Future<List<AdCreateCategory>> fetchChildren(int parentId) async {
    final res = await _dio.get('/categories/$parentId/children');
    return _parseItems<AdCreateCategory>(
      res.data,
      (json) => AdCreateCategory.fromJson(json),
    );
  }

  Future<List<AdCreateAttribute>> fetchAttributes(int categoryId) async {
    final res = await _dio.get('/categories/$categoryId/attributes');
    return _parseItems<AdCreateAttribute>(
      res.data,
      (json) => AdCreateAttribute.fromJson(json),
    );
  }

  Future<AdCreateResponse> submit(AdCreateRequest request) async {
    final payload = <String, dynamic>{
      'category_id': request.categoryId.toString(),
      'city_id': request.cityId.toString(),
      'price': request.price.toString(),
      'currency': request.currency,
      'condition': request.condition,
      'description': request.description ?? '',
      'contact_name': request.contactName ?? '',
      'contact_email': request.contactEmail ?? '',
      'contact_phone': request.contactPhone ?? '',
      'contact_method': request.contactMethod ?? '',
      'has_delivery': request.hasDelivery ? '1' : '0',
      'post_as_store': request.postAsStore ? '1' : '0',
      'cover_index': request.coverIndex.toString(),
    };

    if (request.districtId != null) {
      payload['district_id'] = request.districtId.toString();
    }

    request.attributes.forEach((key, value) {
      if (value == null) return;

      if (value is List) {
        payload['attr[$key][]'] = value.map((e) => e.toString()).toList();
      } else {
        payload['attr[$key]'] = value.toString();
      }
    });

    payload['images[]'] = await Future.wait(
      request.images.map(
        (image) => MultipartFile.fromFile(
          image.file.path,
          filename: image.file.path.split(Platform.pathSeparator).last,
        ),
      ),
    );

    final res = await _dio.post(
      '/account/ads',
      data: FormData.fromMap(payload),
    );

    return AdCreateResponse.fromJson(_asMap(res.data));
  }

  List<T> _parseItems<T>(
    dynamic body,
    T Function(Map<String, dynamic> json) mapper,
  ) {
    final map = _asMap(body);
    final data = map['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => mapper(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((e) => mapper(Map<String, dynamic>.from(e)))
          .toList();
    }

    return <T>[];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}