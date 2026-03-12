import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/message_repo.dart';
import '../models/message_models.dart';

class MessageThreadState {
  final bool loading;
  final MessageThreadHeader? header;
  final List<MessageItem> messages;
  final String? error;
  final bool sending;

  const MessageThreadState({
    this.loading = false,
    this.header,
    this.messages = const [],
    this.error,
    this.sending = false,
  });

  int get lastId => messages.isEmpty ? (header?.lastId ?? 0) : messages.last.id;

  MessageThreadState copyWith({
    bool? loading,
    MessageThreadHeader? header,
    List<MessageItem>? messages,
    String? error,
    bool? sending,
  }) {
    return MessageThreadState(
      loading: loading ?? this.loading,
      header: header ?? this.header,
      messages: messages ?? this.messages,
      error: error,
      sending: sending ?? this.sending,
    );
  }
}

class MessageThreadArgs {
  final int partnerId;
  final int? adId;

  const MessageThreadArgs({
    required this.partnerId,
    this.adId,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MessageThreadArgs &&
            other.partnerId == partnerId &&
            other.adId == adId);
  }

  @override
  int get hashCode => Object.hash(partnerId, adId);
}

final messageThreadControllerProvider = StateNotifierProvider.autoDispose
    .family<MessageThreadController, MessageThreadState, MessageThreadArgs>(
  (ref, args) => MessageThreadController(ref, args),
);

class MessageThreadController extends StateNotifier<MessageThreadState> {
  final Ref ref;
  final MessageThreadArgs args;

  Timer? _pollTimer;
  Timer? _presenceTimer;
  bool _busyPolling = false;
  bool _started = false;

  MessageThreadController(this.ref, this.args)
      : super(const MessageThreadState(loading: true)) {
    ref.onDispose(() {
      _pollTimer?.cancel();
      _presenceTimer?.cancel();
    });

    load();
  }

  Future<void> load() async {
    try {
      state = state.copyWith(loading: true, error: null);

      final detail = await ref.read(messageRepoProvider).fetchThread(
            partnerId: args.partnerId,
            adId: args.adId,
          );

      state = state.copyWith(
        loading: false,
        header: detail.thread,
        messages: detail.messages,
        error: null,
      );

      if (!_started) {
        _started = true;
        _startPolling();
        _startPresencePing();
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> reload() async {
    await load();
  }

  Future<void> sendText(String text) async {
    if (state.sending) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    try {
      state = state.copyWith(sending: true);

      final msg = await ref.read(messageRepoProvider).sendMessage(
            to: args.partnerId,
            body: trimmed,
            adId: args.adId,
          );

      final exists = state.messages.any((m) => m.id == msg.id);
      final List<MessageItem> updated = exists
          ? List<MessageItem>.from(state.messages)
          : <MessageItem>[...state.messages, msg];

      state = state.copyWith(
        messages: updated,
        sending: false,
      );
    } catch (e) {
      state = state.copyWith(sending: false);
      rethrow;
    }
  }

  Future<void> sendImage(MultipartFile image) async {
    if (state.sending) return;

    try {
      state = state.copyWith(sending: true);

      final msg = await ref.read(messageRepoProvider).sendMessage(
            to: args.partnerId,
            adId: args.adId,
            image: image,
          );

      final exists = state.messages.any((m) => m.id == msg.id);
      final List<MessageItem> updated = exists
          ? List<MessageItem>.from(state.messages)
          : <MessageItem>[...state.messages, msg];

      state = state.copyWith(
        messages: updated,
        sending: false,
      );
    } catch (e) {
      state = state.copyWith(sending: false);
      rethrow;
    }
  }

  Future<void> pollNow() async {
    if (_busyPolling) return;
    if (state.loading || state.header == null) return;

    _busyPolling = true;

    try {
      final updates = await ref.read(messageRepoProvider).fetchUpdates(
            partnerId: args.partnerId,
            adId: args.adId,
            afterId: state.lastId,
          );

      if (updates.isNotEmpty) {
        final existingIds = state.messages.map((e) => e.id).toSet();
        final fresh = updates.where((m) => !existingIds.contains(m.id)).toList();

        if (fresh.isNotEmpty) {
          state = state.copyWith(
            messages: <MessageItem>[...state.messages, ...fresh],
          );
        }
      }
    } catch (_) {
      // səssiz keç
    } finally {
      _busyPolling = false;
    }
  }

  Future<void> toggleBlock() async {
    final header = state.header;
    if (header == null) return;

    final blocked =
        await ref.read(messageRepoProvider).toggleBlock(args.partnerId);

    state = state.copyWith(
      header: MessageThreadHeader(
        partner: header.partner,
        ad: header.ad,
        threadType: header.threadType,
        isBlocked: blocked,
        lastId: state.lastId,
      ),
    );
  }

  Future<void> deleteConversation() async {
    await ref.read(messageRepoProvider).deleteConversation(args.partnerId);
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      pollNow();
    });
  }

  void _startPresencePing() {
    _presenceTimer?.cancel();
    _presenceTimer = Timer.periodic(const Duration(seconds: 40), (_) {
      ref.read(messageRepoProvider).pingPresence();
    });

    ref.read(messageRepoProvider).pingPresence();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _presenceTimer?.cancel();
    super.dispose();
  }
}