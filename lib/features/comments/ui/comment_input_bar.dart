import 'package:flutter/material.dart';

class CommentInputBar extends StatelessWidget {
  const CommentInputBar({
    super.key,
    required this.controller,
    required this.posting,
    required this.onSend,
    required this.replyToActive,
    required this.onCancelReply,
  });

  final TextEditingController controller;
  final bool posting;
  final VoidCallback onSend;
  final bool replyToActive;
  final VoidCallback onCancelReply;

  @override
  Widget build(BuildContext context) {
    final viewInset = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (replyToActive)
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
                  onPressed: onCancelReply,
                  child: const Text('Ləğv et'),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(14, 10, 14, 14 + viewInset),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
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
                onTap: posting ? null : onSend,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: posting ? Colors.white24 : Colors.orange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: posting
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
    );
  }
}