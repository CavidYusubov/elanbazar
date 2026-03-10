import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'models/account_models.dart';

final accountRepoProvider = Provider<AccountRepo>((ref) => AccountRepo());

class AccountRepo {
  Dio get _dio => ApiClient.I.dio;

  Future<AccountResponse> fetchAccount() async {
    final res = await _dio.get('/account');
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      return AccountResponse.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    }

    throw Exception('Account fetch failed');
  }

  Future<List<AccountAdItem>> fetchAds({
    required String tab,
    int page = 1,
  }) async {
    final res = await _dio.get('/account/ads', queryParameters: {
      'tab': tab,
      'page': page,
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      final data = Map<String, dynamic>.from(body['data']);
      final items = (data['items'] as List? ?? []);
      return items
          .map((e) => AccountAdItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception('Ads fetch failed');
  }

  Future<void> archiveAd(int adId) async {
    final res = await _dio.post('/account/ads/$adId/archive');
    final body = res.data;

    if (!(body is Map && body['ok'] == true)) {
      throw Exception(
        body is Map ? (body['message'] ?? 'Archive failed') : 'Archive failed',
      );
    }
  }

  Future<void> restoreAd(int adId) async {
    final res = await _dio.post('/account/ads/$adId/restore');
    final body = res.data;

    if (!(body is Map && body['ok'] == true)) {
      throw Exception(
        body is Map ? (body['message'] ?? 'Restore failed') : 'Restore failed',
      );
    }
  }

  Future<AccountUser> updateProfile({
    required String name,
    String? phone,
  }) async {
    final res = await _dio.put('/account/profile', data: {
      'name': name,
      'phone': phone,
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      return AccountUser.fromJson(
        Map<String, dynamic>.from(body['data']['user']),
      );
    }

    throw Exception('Profile update failed');
  }

  Future<AccountUser> updateEmail({
    required String email,
  }) async {
    final res = await _dio.put('/account/profile/email', data: {
      'email': email,
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      return AccountUser.fromJson(
        Map<String, dynamic>.from(body['data']['user']),
      );
    }

    throw Exception('Email update failed');
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _dio.put('/account/profile/password', data: {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    final body = res.data;
    if (!(body is Map && body['ok'] == true)) {
      throw Exception(
        body is Map
            ? (body['message'] ?? 'Password update failed')
            : 'Password update failed',
      );
    }
  }

  Future<AccountUser> uploadPhoto(File file) async {
    final form = FormData.fromMap({
      'photo': await MultipartFile.fromFile(file.path),
    });

    final res = await _dio.post('/account/photo', data: form);

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      return AccountUser.fromJson(
        Map<String, dynamic>.from(body['data']['user']),
      );
    }

    throw Exception('Photo upload failed');
  }

  Future<FollowListResponse> fetchFollowing({int page = 1}) async {
    final res = await _dio.get('/account/following', queryParameters: {
      'page': page,
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      return FollowListResponse.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    }

    throw Exception('Following fetch failed');
  }

  Future<FollowListResponse> fetchFollowers({int page = 1}) async {
    final res = await _dio.get('/account/followers', queryParameters: {
      'page': page,
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      return FollowListResponse.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    }

    throw Exception('Followers fetch failed');
  }

  Future<WalletResponse> fetchWallet() async {
    final res = await _dio.get('/account/wallet');
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      return WalletResponse.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    }

    throw Exception('Wallet fetch failed');
  }

  Future<WalletTransactionsResponse> fetchTransactions({
    String tab = 'personal',
    int page = 1,
  }) async {
    final res = await _dio.get('/account/wallet/transactions', queryParameters: {
      'tab': tab,
      'page': page,
    });

    final body = res.data;
    if (body is Map && body['ok'] == true) {
      return WalletTransactionsResponse.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    }

    throw Exception('Transactions fetch failed');
  }

  Future<List<LimitItem>> fetchLimits() async {
    final res = await _dio.get('/account/wallet/limits');
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = Map<String, dynamic>.from(body['data']);
      final items = (data['items'] as List? ?? []);
      return items
          .map((e) => LimitItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception('Limits fetch failed');
  }
}