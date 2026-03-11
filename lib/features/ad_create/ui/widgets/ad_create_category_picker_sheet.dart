import 'package:flutter/material.dart';

import '../../models/ad_create_category.dart';

class AdCreateCategoryPickerSheet extends StatelessWidget {
  final List<AdCreateCategory> roots;
  final List<AdCreateCategory> level2;
  final List<AdCreateCategory> level3;
  final AdCreateCategory? selectedRoot;
  final AdCreateCategory? selectedLevel2;
  final AdCreateCategory? selectedLeaf;
  final Future<void> Function(AdCreateCategory category) onSelectRoot;
  final Future<void> Function(AdCreateCategory category) onSelectLevel2;
  final Future<void> Function(AdCreateCategory category) onSelectLeaf;

  const AdCreateCategoryPickerSheet({
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
    final currentLevelItems = level3.isNotEmpty
        ? level3
        : (level2.isNotEmpty ? level2 : roots);

    final title = level3.isNotEmpty
        ? '3-cü səviyyə'
        : (level2.isNotEmpty ? 'Alt kateqoriya' : 'Kateqoriya seç');

    return Scaffold(
      backgroundColor: const Color(0xff090b10),
      appBar: AppBar(
        backgroundColor: const Color(0xff090b10),
        elevation: 0,
        title: const Text(
          'Kateqoriya seç',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_pathText().isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xff111318),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  _pathText(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .95,
                ),
                itemCount: currentLevelItems.length,
                itemBuilder: (context, index) {
                  final item = currentLevelItems[index];
                  final selected = selectedLeaf?.id == item.id ||
                      (level3.isEmpty && selectedLevel2?.id == item.id) ||
                      (level2.isEmpty && selectedRoot?.id == item.id);

                  return GestureDetector(
                    onTap: () async {
                      if (level2.isEmpty) {
                        await onSelectRoot(item);
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => AdCreateCategoryPickerSheet(
                                roots: roots,
                                level2: const [],
                                level3: const [],
                                selectedRoot: item,
                                selectedLevel2: null,
                                selectedLeaf: null,
                                onSelectRoot: onSelectRoot,
                                onSelectLevel2: onSelectLevel2,
                                onSelectLeaf: onSelectLeaf,
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      if (level3.isEmpty) {
                        await onSelectLevel2(item);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        return;
                      }

                      await onSelectLeaf(item);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xff12bf82) : const Color(0xff141821),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected ? const Color(0xff12bf82) : Colors.white10,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              color: selected ? Colors.white.withValues(alpha: .18) : const Color(0xff1f2430),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _pathText() {
    final parts = <String>[
      if (selectedRoot != null) selectedRoot!.name,
      if (selectedLevel2 != null) selectedLevel2!.name,
      if (selectedLeaf != null &&
          selectedLeaf!.id != selectedLevel2?.id &&
          selectedLeaf!.id != selectedRoot?.id)
        selectedLeaf!.name,
    ];
    return parts.join(' / ');
  }
}