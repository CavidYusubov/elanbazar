import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/message_repo.dart';

final messagesUnreadControllerProvider =
    StateNotifierProvider<MessagesUnreadController, int>(
  (ref) => MessagesUnreadController(ref),
);

class MessagesUnreadController extends StateNotifier<int> {
  final Ref ref;
  Timer? _timer;

  MessagesUnreadController(this.ref) : super(0) {
    load();

    _timer = Timer.periodic(const Duration(seconds: 12), (_) {
      load();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });
  }

  Future<void> load() async {
    try {
      final count = await ref.read(messageRepoProvider).fetchUnreadCount();
      if (mounted) {
        state = count;
      }
    } catch (_) {
      // unread badge üçün sakit keçirik
    }
  }

  Future<void> refresh() async {
    await load();
  }
}