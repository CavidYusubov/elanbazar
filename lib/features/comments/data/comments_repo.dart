import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/comments_page.dart';
import '../models/ad_comment.dart';

class CommentsRepo {
  CommentsRepo(this._api);
  final ApiClient _api;

  Future<CommentsPage> fetchComments(int adId, {int page = 1}) async {
    final res = await _api.dio.get(
      '/ads/$adId/comments',
      queryParameters: {'page': page, 'per_page': 20},
    );
    return CommentsPage.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<AdComment> createComment({
    required int adId,
    required String body,
    int? parentId,
  }) async {
    final res = await _api.dio.post(
      '/ads/$adId/comments',
      data: {
        'body': body,
        if (parentId != null) 'parent_id': parentId,
      },
    );

    return AdComment.fromJson(
      Map<String, dynamic>.from(res.data['data'] as Map),
    );
  }

  Future<AdComment> updateComment({
    required int commentId,
    required String body,
  }) async {
    final res = await _api.dio.put(
      '/comments/$commentId',
      data: {'body': body},
    );

    return AdComment.fromJson(
      Map<String, dynamic>.from(res.data['data'] as Map),
    );
  }

  Future<void> deleteComment(int commentId) async {
    await _api.dio.delete('/comments/$commentId');
  }

  Future<Map<String, dynamic>> toggleLike(int commentId) async {
    final res = await _api.dio.post('/comments/$commentId/like');
    return Map<String, dynamic>.from(res.data);
  }
}