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
  });

  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onMore;
  final String? avatarUrl;
  final int likeCount;
  final int commentCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 22, backgroundColor: Colors.white24, child: const Icon(Icons.person, color: Colors.white)),
        const SizedBox(height: 18),
        _btn(Icons.favorite_border, '$likeCount', onLike),
        const SizedBox(height: 14),
        _btn(Icons.chat_bubble_outline, '$commentCount', onComment),
        const SizedBox(height: 14),
        _btn(Icons.more_horiz, '', onMore),
      ],
    );
  }

  Widget _btn(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ]
        ],
      ),
    );
  }
}