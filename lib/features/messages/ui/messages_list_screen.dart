import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_models.dart';
import '../state/messages_list_controller.dart';
import '../state/messages_unread_controller.dart';
import 'message_thread_screen.dart';

class MessagesListScreen extends ConsumerStatefulWidget {
  const MessagesListScreen({super.key});

  @override
  ConsumerState<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends ConsumerState<MessagesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(messagesUnreadControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(messagesTabProvider);
    final state = ref.watch(messagesListControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070A0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1018),
              Color(0xFF090C12),
              Color(0xFF06080C),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _MessagesTopHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: _MessagesTabs(
                  current: tab,
                  onChanged: (value) async {
                    await ref
                        .read(messagesListControllerProvider.notifier)
                        .changeTab(value);
                  },
                ),
              ),
              Expanded(
                child: state.when(
                  loading: () => const _MessagesLoadingView(),
                  error: (e, _) => _MessagesErrorView(
                    text: '$e',
                    onRetry: () =>
                        ref.read(messagesListControllerProvider.notifier).refresh(),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return const _MessagesEmptyView();
                    }

                    return RefreshIndicator(
                      color: const Color(0xFF12BF82),
                      backgroundColor: const Color(0xFF111827),
                      onRefresh: () async {
                        await ref
                            .read(messagesListControllerProvider.notifier)
                            .refresh();
                        await ref
                            .read(messagesUnreadControllerProvider.notifier)
                            .refresh();
                      },
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _ThreadCard(
                            item: item,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MessageThreadScreen(
                                    partnerId: item.partner.id,
                                    adId: item.thread.adId,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              await ref
                                  .read(messagesListControllerProvider.notifier)
                                  .refresh();
                              await ref
                                  .read(messagesUnreadControllerProvider.notifier)
                                  .refresh();
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesTopHeader extends StatelessWidget {
  const _MessagesTopHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mesajlar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Satıcılar və alıcılarla yazışmalar',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(.05),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: Color(0xFF12BF82),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagesTabs extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _MessagesTabs({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _TabChip(
            label: 'Hamısı',
            value: 'all',
            current: current,
            onTap: onChanged,
          ),
          _TabChip(
            label: 'Alış',
            value: 'buy',
            current: current,
            onTap: onChanged,
          ),
          _TabChip(
            label: 'Satış',
            value: 'sell',
            current: current,
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  const _TabChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      Color(0xFF1DE2A0),
                      Color(0xFF12BF82),
                    ],
                  )
                : null,
            color: selected ? null : Colors.transparent,
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x4412BF82),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final MessageThreadListItem item;
  final VoidCallback onTap;

  const _ThreadCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final partner = item.partner;
    final thread = item.thread;
    final ad = item.ad;

    final unread = thread.unreadCount;
    final time = thread.lastMessage.timeLabel ?? '';
    final preview = thread.lastMessage.preview;
    final avatar = partner.avatarUrl;
    final isOnline = partner.isOnline;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withOpacity(.045),
          child: InkWell(
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Colors.white.withOpacity(.045),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1DE2A0),
                              Color(0xFF12BF82),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF111827),
                            child: ClipOval(
                              child: (avatar != null && avatar.trim().isNotEmpty)
                                  ? Image.network(
                                      avatar,
                                      width: 54,
                                      height: 54,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.person, color: Colors.white),
                                    )
                                  : const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0B1018),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                partner.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              time,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (ad != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.sell_rounded,
                                  size: 15,
                                  color: Color(0xFF12BF82),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    ad.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFD7DEE9),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                preview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFB8C2D1),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (unread > 0) ...[
                              const SizedBox(width: 10),
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 22,
                                  minHeight: 22,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    unread > 99 ? '99+' : '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessagesLoadingView extends StatelessWidget {
  const _MessagesLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF12BF82),
      ),
    );
  }
}

class _MessagesEmptyView extends StatelessWidget {
  const _MessagesEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Colors.white.withOpacity(.05),
              ),
              child: const Icon(
                Icons.mark_chat_unread_rounded,
                color: Color(0xFF12BF82),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hələ mesaj yoxdur',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elan sahibləri ilə yazışmalar burada görünəcək.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesErrorView extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _MessagesErrorView({
    required this.text,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD7DEE9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12BF82),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Yenidən cəhd et'),
            ),
          ],
        ),
      ),
    );
  }
}