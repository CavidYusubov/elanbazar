import 'package:flutter/material.dart';
import '../models/ad_comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
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
                backgroundImage:
                    (item.user.photoUrl != null && item.user.photoUrl!.isNotEmpty)
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
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.4,
                      ),
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
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 46, top: 4),
            child: Wrap(
              spacing: 14,
              runSpacing: 6,
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
                        const Icon(
                          Icons.subdirectory_arrow_right,
                          color: Colors.white24,
                          size: 16,
                        ),
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
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
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