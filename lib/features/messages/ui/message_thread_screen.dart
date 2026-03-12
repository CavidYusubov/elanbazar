import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_models.dart';
import '../state/message_thread_controller.dart';
import '../state/messages_unread_controller.dart';

class MessageThreadScreen extends ConsumerStatefulWidget {
  final int partnerId;
  final int? adId;

  const MessageThreadScreen({
    super.key,
    required this.partnerId,
    this.adId,
  });

  @override
  ConsumerState<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final MessageThreadArgs args;

  bool _submitting = false;
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    args = MessageThreadArgs(
      partnerId: widget.partnerId,
      adId: widget.adId,
    );
  }

  @override
  void dispose() {
    ref.invalidate(messageThreadControllerProvider(args));
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _prettyError(Object e) {
    final raw = e.toString().trim();

    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '').trim();
    }

    if (raw.startsWith('DioException: ')) {
      return 'Mesaj göndərilmədi';
    }

    return raw.isEmpty ? 'Mesaj göndərilmədi' : raw;
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final max = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(max);
      }
    });
  }

  Future<void> _sendText() async {
    if (_submitting) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);

    try {
      await ref.read(messageThreadControllerProvider(args).notifier).sendText(text);

      if (!mounted) return;

      _textController.clear();
      _scrollToBottom();
      ref.read(messagesUnreadControllerProvider.notifier).refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_prettyError(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_submitting) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _submitting = true);

    try {
      final multipart = await MultipartFile.fromFile(
        file.path,
        filename: file.name,
      );

      await ref
          .read(messageThreadControllerProvider(args).notifier)
          .sendImage(multipart);

      if (!mounted) return;

      _scrollToBottom();
      ref.read(messagesUnreadControllerProvider.notifier).refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_prettyError(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageThreadControllerProvider(args));
    final controller = ref.read(messageThreadControllerProvider(args).notifier);

    ref.listen<MessageThreadState>(
      messageThreadControllerProvider(args),
      (prev, next) {
        final prevLen = prev?.messages.length ?? 0;
        final nextLen = next.messages.length;

        if (!_didInitialScroll && !next.loading && next.messages.isNotEmpty) {
          _didInitialScroll = true;
          _scrollToBottom(animated: false);
          return;
        }

        if (nextLen > prevLen) {
          _scrollToBottom();
        }
      },
    );

    final busy = state.sending || _submitting;

    return Scaffold(
      backgroundColor: const Color(0xFF070A0F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1017),
              Color(0xFF0A0D13),
              Color(0xFF06080C),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _ThreadTopBar(
                header: state.header,
                onBack: () async {
                  await ref.read(messagesUnreadControllerProvider.notifier).refresh();
                  if (mounted) Navigator.of(context).pop();
                },
                onBlock: () async {
                  await controller.toggleBlock();
                  if (!mounted) return;

                  final blocked = ref
                          .read(messageThreadControllerProvider(args))
                          .header
                          ?.isBlocked ??
                      false;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(blocked ? 'Bloklandı' : 'Blokdan çıxarıldı'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onDelete: () async {
                  await controller.deleteConversation();
                  if (!mounted) return;
                  await ref.read(messagesUnreadControllerProvider.notifier).refresh();
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              if (state.header?.ad != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                  child: _AdStrip(ad: state.header!.ad!),
                ),
              Expanded(
                child: state.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF12BF82),
                        ),
                      )
                    : state.error != null
                        ? _ThreadErrorView(
                            text: state.error!,
                            onRetry: controller.reload,
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final m = state.messages[index];
                              return _MessageBubble(item: m);
                            },
                          ),
              ),
              _ThreadComposer(
                controller: _textController,
                busy: busy,
                onAttach: _pickAndSendImage,
                onSend: _sendText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadTopBar extends StatelessWidget {
  final MessageThreadHeader? header;
  final VoidCallback onBack;
  final VoidCallback onBlock;
  final VoidCallback onDelete;

  const _ThreadTopBar({
    required this.header,
    required this.onBack,
    required this.onBlock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final partner = header?.partner;
    final avatar = partner?.avatarUrl;
    final isOnline = partner?.isOnline == true;
    final subtitle =
        partner == null ? '' : (isOnline ? 'Onlayn' : (partner.lastSeenHuman ?? ''));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _GlassCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
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
                                          width: 42,
                                          height: 42,
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
                              right: 1,
                              bottom: 1,
                              child: Container(
                                width: 13,
                                height: 13,
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: partner == null
                            ? const Text(
                                'Mesaj',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    partner.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isOnline
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
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
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            color: const Color(0xFF111827),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'block') {
                onBlock();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'block',
                child: Text(
                  (header?.isBlocked ?? false) ? 'Blokdan çıxar' : 'Blok et',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Yazışmanı sil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            child: const _GlassCircleButton(
              icon: Icons.more_vert_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdStrip extends StatelessWidget {
  final MessageAdMini ad;

  const _AdStrip({required this.ad});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.045),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ad.imageUrl != null
                    ? Image.network(
                        ad.imageUrl!,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 58,
                          height: 58,
                          color: Colors.white.withOpacity(.08),
                          child: const Icon(Icons.image, color: Colors.white70),
                        ),
                      )
                    : Container(
                        width: 58,
                        height: 58,
                        color: Colors.white.withOpacity(.08),
                        child: const Icon(Icons.image, color: Colors.white70),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.priceFormatted ?? '',
                      style: const TextStyle(
                        color: Color(0xFF12BF82),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageItem item;

  const _MessageBubble({required this.item});

  @override
  Widget build(BuildContext context) {
    final isMe = item.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: isMe
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2EA8FF),
                        Color(0xFF198CFF),
                      ],
                    )
                  : null,
              color: isMe ? null : Colors.white.withOpacity(.07),
              boxShadow: isMe
                  ? const [
                      BoxShadow(
                        color: Color(0x33198CFF),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (item.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          item.imageUrl!,
                          width: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 220,
                            height: 150,
                            color: Colors.white.withOpacity(.08),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if ((item.body ?? '').isNotEmpty)
                    Text(
                      item.body!,
                      style: TextStyle(
                        color: isMe ? Colors.white : const Color(0xFFE5E7EB),
                        fontWeight: FontWeight.w500,
                        fontSize: 14.5,
                        height: 1.35,
                      ),
                    ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMe)
                        Icon(
                          Icons.done_all_rounded,
                          size: 15,
                          color: item.isReadByOther
                              ? const Color(0xFF86EFAC)
                              : Colors.white70,
                        ),
                      if (isMe) const SizedBox(width: 4),
                      Text(
                        item.timeLabel ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _ThreadComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const _ThreadComposer({
    required this.controller,
    required this.busy,
    required this.onAttach,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.055),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  _ComposerIconButton(
                    icon: Icons.attach_file_rounded,
                    onTap: busy ? null : onAttach,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Mesajınızı bura yazın...',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: busy ? null : onSend,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: busy
                            ? null
                            : const LinearGradient(
                                colors: [
                                  Color(0xFF8B5CF6),
                                  Color(0xFF7C3AED),
                                ],
                              ),
                        color: busy ? Colors.white.withOpacity(.08) : null,
                        boxShadow: busy
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x447C3AED),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                      ),
                      child: Center(
                        child: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
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

class _ComposerIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ComposerIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(.06),
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.white38 : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _GlassCircleButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.055),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );

    if (onTap == null) return child;

    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}

class _ThreadErrorView extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _ThreadErrorView({
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
              Icons.chat_bubble_outline_rounded,
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