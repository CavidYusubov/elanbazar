import 'package:flutter/material.dart';

class ReelActions extends StatelessWidget {
  const ReelActions({
    super.key,
    required this.onLike,
    required this.onComment,
    required this.onMore,
    required this.avatarUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isFavorite,
    this.onAvatarTap,
  });

  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onMore;
  final VoidCallback? onAvatarTap;

  final String? avatarUrl;
  final int likeCount;
  final int commentCount;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 18),
        _btn(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          '$likeCount',
          onLike,
          color: isFavorite ? Colors.red : Colors.white,
        ),
        const SizedBox(height: 14),
        _btn(Icons.chat_bubble_outline, '$commentCount', onComment),
        const SizedBox(height: 14),
        _btn(Icons.more_horiz, '', onMore),
      ],
    );
  }

  Widget _btn(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]
        ],
      ),
    );
  }
}