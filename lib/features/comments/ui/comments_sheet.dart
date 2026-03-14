import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/auth_screen.dart';
import '../state/ad_comments_controller.dart';
import '../models/ad_comment.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  const CommentsSheet({
    super.key,
    required this.adId,
  });

  final int adId;

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int? _replyTo;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
        ref.read(adCommentsControllerProvider(widget.adId).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final auth = ref.read(authControllerProvider);
    if (auth.user == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (!mounted) return;
      final after = ref.read(authControllerProvider);
      if (after.user == null) return;
    }

    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    try {
      await ref.read(adCommentsControllerProvider(widget.adId).notifier)
          .postComment(text, parentId: _replyTo);

      _ctrl.clear();
      setState(() => _replyTo = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xəta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(adCommentsControllerProvider(widget.adId));

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: const BoxDecoration(
          color: Color(0xFF111318),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Şərhlər ${st.totalCount > 0 ? "(${st.totalCount})" : ""}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: st.loading
                  ? const Center(child: CircularProgressIndicator())
                  : st.items.isEmpty
                      ? const Center(
                          child: Text(
                            'Hələ şərh yoxdur',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                          itemCount: st.items.length + (st.loadingMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i >= st.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final c = st.items[i];
                            return _CommentTile(
                              item: c,
                              onReply: () => setState(() => _replyTo = c.id),
                              onLike: () => ref
                                  .read(adCommentsControllerProvider(widget.adId).notifier)
                                  .toggleLike(c.id),
                              onDelete: c.isMine
                                  ? () => ref
                                      .read(adCommentsControllerProvider(widget.adId).notifier)
                                      .deleteComment(c.id)
                                  : null,
                            );
                          },
                        ),
            ),
            if (_replyTo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Row(
                  children: [
                    const Icon(Icons.reply, color: Colors.white54, size: 16),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Cavab yazılır',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _replyTo = null),
                      child: const Text('Ləğv et'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                10,
                14,
                14 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Şərh yaz...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: st.posting ? null : _send,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: st.posting ? Colors.white24 : Colors.orange,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: st.posting
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.item,
    required this.onReply,
    required this.onLike,
    this.onDelete,
  });

  final AdComment item;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: (item.user.photoUrl != null && item.user.photoUrl!.isNotEmpty)
                    ? NetworkImage(item.user.photoUrl!)
                    : null,
                backgroundColor: Colors.white12,
                child: (item.user.photoUrl == null || item.user.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: onLike,
                    icon: Icon(
                      item.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: item.isLiked ? Colors.red : Colors.white70,
                      size: 20,
                    ),
                  ),
                  Text(
                    '${item.likesCount}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 46, top: 4),
            child: Wrap(
              spacing: 14,
              children: [
                GestureDetector(
                  onTap: onReply,
                  child: const Text(
                    'Cavab ver',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (item.isEdited)
                  const Text(
                    'redaktə edildi',
                    style: TextStyle(color: Colors.white38),
                  ),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: const Text(
                      'Sil',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (item.latestReplies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 10),
              child: Column(
                children: item.latestReplies.map((r) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.subdirectory_arrow_right, color: Colors.white24, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${r.user.name}  ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: r.body,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}