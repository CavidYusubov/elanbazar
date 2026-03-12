import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/message_repo.dart';
import '../models/message_models.dart';



final messagesTabProvider = StateProvider<String>((ref) => 'all');

final messagesListControllerProvider =
    StateNotifierProvider<MessagesListController, AsyncValue<List<MessageThreadListItem>>>(
  (ref) => MessagesListController(ref),
);

class MessagesListController
    extends StateNotifier<AsyncValue<List<MessageThreadListItem>>> {
  final Ref ref;

  MessagesListController(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final tab = ref.read(messagesTabProvider);
      final items = await ref.read(messageRepoProvider).fetchThreads(tab: tab);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> changeTab(String tab) async {
    ref.read(messagesTabProvider.notifier).state = tab;
    await load();
  }

  Future<void> refresh() async {
    await load();
  }
}