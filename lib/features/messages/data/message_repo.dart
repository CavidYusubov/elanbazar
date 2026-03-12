import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/message_models.dart';

final messageRepoProvider = Provider<MessageRepo>((ref) {
  return MessageRepo();
});

class MessageRepo {
  bool _isOk(dynamic body) {
    return body is Map && (body['ok'] == true || body['success'] == true);
  }

  Map<String, dynamic>? _extractPayload(dynamic body) {
    if (body is! Map) return null;

    final map = Map<String, dynamic>.from(body);
    final data = map['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return map;
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  Future<List<MessageThreadListItem>> fetchThreads({String tab = 'all'}) async {
    final res = await ApiClient.I.dio.get(
      '/messages/threads',
      queryParameters: {'tab': tab},
    );

    final body = res.data;
    if (_isOk(body)) {
      final payload = _extractPayload(body);
      if (payload != null) {
        final items = payload['items'];
        if (items is List) {
          return items
              .map((e) => MessageThreadListItem.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList();
        }
      }
    }

    throw Exception('Mesaj siyahısı alınmadı');
  }

  Future<MessageThreadDetail> fetchThread({
    required int partnerId,
    int? adId,
  }) async {
    final res = await ApiClient.I.dio.get(
      '/messages/threads/$partnerId',
      queryParameters: {
        if (adId != null) 'ad_id': adId,
      },
    );

    final body = res.data;
    if (_isOk(body)) {
      final payload = _extractPayload(body);
      if (payload != null) {
        final threadMap = payload['thread'];
        final messagesRaw = payload['messages'];

        if (threadMap is Map && messagesRaw is List) {
          final thread =
              MessageThreadHeader.fromJson(Map<String, dynamic>.from(threadMap));

          final messages = messagesRaw
              .map((e) => MessageItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          return MessageThreadDetail(
            thread: thread,
            messages: messages,
            lastId: thread.lastId,
          );
        }
      }
    }

    throw Exception('Yazışma açıla bilmədi');
  }

  Future<List<MessageItem>> fetchUpdates({
    required int partnerId,
    required int afterId,
    int? adId,
  }) async {
    final res = await ApiClient.I.dio.get(
      '/messages/threads/$partnerId/updates',
      queryParameters: {
        'after_id': afterId,
        if (adId != null) 'ad_id': adId,
      },
    );

    final body = res.data;
    if (_isOk(body)) {
      final payload = _extractPayload(body);
      if (payload != null) {
        final messagesRaw = payload['messages'];
        if (messagesRaw is List) {
          return messagesRaw
              .map((e) => MessageItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    }

    throw Exception('Yeni mesajlar alınmadı');
  }

  Future<MessageItem> sendMessage({
    required int to,
    String? body,
    int? adId,
    MultipartFile? image,
  }) async {
    try {
      final trimmedBody = body?.trim();

      final formData = FormData.fromMap({
        'to': to,
        if (trimmedBody != null && trimmedBody.isNotEmpty) 'body': trimmedBody,
        if (adId != null) 'ad_id': adId,
        if (image != null) 'image': image,
      });

      final res = await ApiClient.I.dio.post(
        '/messages/send',
        data: formData,
      );

      final responseBody = res.data;

      if (_isOk(responseBody)) {
        final payload = _extractPayload(responseBody);

        if (payload != null) {
          final msg = payload['message'];
          if (msg is Map) {
            return MessageItem.fromJson(Map<String, dynamic>.from(msg));
          }

          final data = payload['data'];
          if (data is Map && data.containsKey('id')) {
            return MessageItem.fromJson(Map<String, dynamic>.from(data));
          }

          final dynamic rawId =
              payload['id'] ?? ((data is Map) ? data['id'] : null);
          final int generatedId =
              _asInt(rawId) ?? DateTime.now().millisecondsSinceEpoch;

          final now = DateTime.now();
          final hh = now.hour.toString().padLeft(2, '0');
          final mm = now.minute.toString().padLeft(2, '0');

          return MessageItem(
            id: generatedId,
            senderId: 0,
            receiverId: to,
            adId: adId,
            body: trimmedBody,
            imageUrl: null,
            isSpam: false,
            isRead: false,
            readAt: null,
            createdAt: now.toIso8601String(),
            timeLabel: '$hh:$mm',
            isMe: true,
            isSent: true,
            isReadByOther: false,
          );
        }
      }

      throw Exception('Mesaj göndərilmədi');
    } on DioException catch (e) {
      final body = e.response?.data;

      if (body is Map) {
        final message = body['message'] ?? body['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          throw Exception(message.toString());
        }
      }

      if (e.response?.statusCode == 429) {
        throw Exception('Mesaj çox tez-tez göndərilir');
      }

      throw Exception('Mesaj göndərilmədi');
    }
  }

  Future<bool> toggleBlock(int userId) async {
    final res = await ApiClient.I.dio.post('/messages/block/$userId');
    final body = res.data;

    if (_isOk(body)) {
      final payload = _extractPayload(body);
      if (payload != null) {
        return payload['blocked'] == true;
      }
      return true;
    }

    throw Exception('Blok əməliyyatı baş tutmadı');
  }

  Future<void> deleteConversation(int userId) async {
    final res = await ApiClient.I.dio.delete('/messages/threads/$userId');
    final body = res.data;

    if (_isOk(body)) return;

    throw Exception('Yazışma silinmədi');
  }

  Future<int> fetchUnreadCount() async {
    final res = await ApiClient.I.dio.get('/messages/unread-summary');
    final body = res.data;

    if (_isOk(body)) {
      final payload = _extractPayload(body);
      if (payload != null) {
        return _asInt(payload['total_unread']) ?? 0;
      }
    }

    return 0;
  }

  Future<void> pingPresence() async {
    try {
      await ApiClient.I.dio.post('/presence/ping');
    } catch (_) {}
  }
}