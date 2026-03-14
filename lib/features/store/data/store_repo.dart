import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/store_models.dart';

class StoreRepo {
  StoreRepo({Dio? dio}) : _dio = dio ?? ApiClient.I.dio;

  final Dio _dio;

  Future<StoreMeta> getMeta() async {
    final res = await _dio.get('/account/store/meta');
    return StoreMeta.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<StoreStatusResponse> getMyStore() async {
    final res = await _dio.get('/account/store');
    return StoreStatusResponse.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  Future<StoreDetail> createStore(StoreCreatePayload payload) async {
    final map = <String, dynamic>{
      'name': payload.name,
      'phone': payload.phone,
      if (payload.cityId != null) 'city_id': payload.cityId,
      if ((payload.addressShort ?? '').trim().isNotEmpty)
        'address_short': payload.addressShort!.trim(),
      if ((payload.address ?? '').trim().isNotEmpty)
        'address': payload.address!.trim(),
      if ((payload.workHoursFrom ?? '').trim().isNotEmpty)
        'work_hours_from': payload.workHoursFrom!.trim(),
      if ((payload.workHoursTo ?? '').trim().isNotEmpty)
        'work_hours_to': payload.workHoursTo!.trim(),
      if ((payload.phone2 ?? '').trim().isNotEmpty)
        'phone2': payload.phone2!.trim(),
      if ((payload.phone3 ?? '').trim().isNotEmpty)
        'phone3': payload.phone3!.trim(),
      if ((payload.description ?? '').trim().isNotEmpty)
        'description': payload.description!.trim(),
    };

    if ((payload.logoPath ?? '').isNotEmpty) {
      map['logo'] = await MultipartFile.fromFile(
        payload.logoPath!,
        filename: File(payload.logoPath!).uri.pathSegments.last,
      );
    }

    if ((payload.coverPath ?? '').isNotEmpty) {
      map['cover'] = await MultipartFile.fromFile(
        payload.coverPath!,
        filename: File(payload.coverPath!).uri.pathSegments.last,
      );
    }

    final formData = FormData.fromMap(map);

    final res = await _dio.post(
      '/account/store',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final body = Map<String, dynamic>.from(res.data as Map);
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final storeJson = data['store'] as Map<String, dynamic>? ?? {};

    return StoreDetail.fromJson(storeJson);
  }


  Future<StoreDashboard> getDashboard() async {
  final res = await _dio.get('/account/store/dashboard');
  final body = Map<String, dynamic>.from(res.data as Map);
  final data = body['data'] as Map<String, dynamic>? ?? {};
  final storeJson = data['store'] as Map<String, dynamic>? ?? {};
  return StoreDashboard.fromJson(storeJson);
}


Future<StoreEditMeta> getEditMeta() async {
  final res = await _dio.get('/account/store/edit/meta');
  return StoreEditMeta.fromJson(Map<String, dynamic>.from(res.data as Map));
}

Future<StoreDashboard> updateStore(StoreUpdatePayload payload) async {
  final map = <String, dynamic>{
    'name': payload.name,
    'phone': payload.phone,
    if (payload.cityId != null) 'city_id': payload.cityId,
    if ((payload.addressShort ?? '').trim().isNotEmpty)
      'address_short': payload.addressShort!.trim(),
    if ((payload.address ?? '').trim().isNotEmpty)
      'address': payload.address!.trim(),
    if ((payload.workHoursFrom ?? '').trim().isNotEmpty)
      'work_hours_from': payload.workHoursFrom!.trim(),
    if ((payload.workHoursTo ?? '').trim().isNotEmpty)
      'work_hours_to': payload.workHoursTo!.trim(),
    if ((payload.description ?? '').trim().isNotEmpty)
      'description': payload.description!.trim(),
  };

  if ((payload.logoPath ?? '').isNotEmpty) {
    map['logo'] = await MultipartFile.fromFile(
      payload.logoPath!,
      filename: File(payload.logoPath!).uri.pathSegments.last,
    );
  }

  if ((payload.coverPath ?? '').isNotEmpty) {
    map['cover'] = await MultipartFile.fromFile(
      payload.coverPath!,
      filename: File(payload.coverPath!).uri.pathSegments.last,
    );
  }

  if (payload.galleryPaths.isNotEmpty) {
    map['gallery'] = await Future.wait(
      payload.galleryPaths.map(
        (p) => MultipartFile.fromFile(
          p,
          filename: File(p).uri.pathSegments.last,
        ),
      ),
    );
  }

  final res = await _dio.post(
    '/account/store/edit',
    data: FormData.fromMap(map),
    options: Options(contentType: 'multipart/form-data'),
  );

  final body = Map<String, dynamic>.from(res.data as Map);
  final data = body['data'] as Map<String, dynamic>? ?? {};
  final storeJson = data['store'] as Map<String, dynamic>? ?? {};
  return StoreDashboard.fromJson(storeJson);
}

Future<void> sortGallery(List<int> ids) async {
  await _dio.post(
    '/account/store/gallery/sort',
    data: {'order': ids},
  );
}

Future<void> deleteGalleryImage(int id) async {
  await _dio.delete('/account/store/gallery/$id');
}
}