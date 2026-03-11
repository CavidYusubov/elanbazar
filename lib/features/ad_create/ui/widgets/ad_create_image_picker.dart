import 'dart:io';

import 'package:flutter/material.dart';

class AdCreateImagePicker extends StatelessWidget {
  final List<File> images;
  final int coverIndex;
  final int maxImages;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int index) onSetCover;
  final void Function(int oldIndex, int newIndex) onReorder;

  const AdCreateImagePicker({
    super.key,
    required this.images,
    required this.coverIndex,
    required this.maxImages,
    required this.onAdd,
    required this.onRemove,
    required this.onSetCover,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff111318),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Şəkillər',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff1f2430),
                  foregroundColor: Colors.white,
                ),
                onPressed: images.length >= maxImages ? null : onAdd,
                child: const Text('Əlavə et'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${images.length}/$maxImages şəkil',
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (images.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xff1b1f27),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.photo_library_outlined, color: Colors.white54, size: 34),
                  SizedBox(height: 10),
                  Text(
                    'Hələ şəkil seçilməyib',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final image = images[index];
                final isCover = index == coverIndex;

                return Container(
                  key: ValueKey('${image.path}_$index'),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff1a1d24),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCover ? const Color(0xff12bf82) : Colors.white10,
                      width: isCover ? 1.4 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        image,
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      isCover ? 'Cover şəkil' : 'Şəkil ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      image.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 2,
                      children: [
                        IconButton(
                          onPressed: () => onSetCover(index),
                          icon: Icon(
                            isCover ? Icons.star : Icons.star_border,
                            color: isCover ? const Color(0xff12bf82) : Colors.white70,
                          ),
                        ),
                        IconButton(
                          onPressed: () => onRemove(index),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}