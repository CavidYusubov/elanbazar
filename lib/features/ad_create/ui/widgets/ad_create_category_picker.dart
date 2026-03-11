import 'package:flutter/material.dart';

import '../../models/ad_create_category.dart';

class AdCreateCategoryPicker extends StatelessWidget {
  final List<AdCreateCategory> roots;
  final List<AdCreateCategory> level2;
  final List<AdCreateCategory> level3;
  final AdCreateCategory? selectedRoot;
  final AdCreateCategory? selectedLevel2;
  final AdCreateCategory? selectedLeaf;
  final Future<void> Function(AdCreateCategory category) onSelectRoot;
  final Future<void> Function(AdCreateCategory category) onSelectLevel2;
  final Future<void> Function(AdCreateCategory category) onSelectLeaf;

  const AdCreateCategoryPicker({
    super.key,
    required this.roots,
    required this.level2,
    required this.level3,
    required this.selectedRoot,
    required this.selectedLevel2,
    required this.selectedLeaf,
    required this.onSelectRoot,
    required this.onSelectLevel2,
    required this.onSelectLeaf,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Kateqoriya',
      subtitle: _selectedPath(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChipWrap(
            items: roots,
            selected: selectedRoot?.id,
            onTap: onSelectRoot,
          ),
          if (level2.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Alt kateqoriya',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _buildChipWrap(
              items: level2,
              selected: selectedLevel2?.id,
              onTap: onSelectLevel2,
            ),
          ],
          if (level3.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              '3-cü dərəcə',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _buildChipWrap(
              items: level3,
              selected: selectedLeaf?.id,
              onTap: onSelectLeaf,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChipWrap({
    required List<AdCreateCategory> items,
    required int? selected,
    required Future<void> Function(AdCreateCategory category) onTap,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((cat) {
        final active = selected == cat.id;

        return GestureDetector(
          onTap: () => onTap(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: active ? const Color(0xff12bf82) : const Color(0xff1e222b),
              border: Border.all(
                color: active ? const Color(0xff12bf82) : Colors.white12,
              ),
            ),
            child: Text(
              cat.name,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _selectedPath() {
    final parts = <String>[
      if (selectedRoot != null) selectedRoot!.name,
      if (selectedLevel2 != null) selectedLevel2!.name,
      if (selectedLeaf != null &&
          selectedLeaf!.id != selectedLevel2?.id &&
          selectedLeaf!.id != selectedRoot?.id)
        selectedLeaf!.name,
    ];

    if (parts.isEmpty) return 'Kateqoriya seçilməyib';
    return parts.join(' / ');
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}