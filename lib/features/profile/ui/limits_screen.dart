import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/limits_controller.dart';

class LimitsScreen extends ConsumerWidget {
  const LimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(limitsControllerProvider);
    final controller = ref.read(limitsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        title: const Text('Elan limiti'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: state.loading
            ? const Center(child: CircularProgressIndicator())
            : state.items.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('Limit məlumatı yoxdur')),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(10),
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Kateqoriyalarınız üzrə qalan yerləşdirmələrin sayı',
                          style: TextStyle(
                            color: Color(0xff94a3b8),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ...state.items.map((item) {
                        final open = state.openedIds.contains(item.id);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffe5e7eb)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => controller.toggleOpen(item.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff3f4f6),
                                          border: Border.all(color: const Color(0xffe5e7eb)),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.grid_view_rounded),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                              ),
                                            ),
                                            if ((item.parentName ?? '').isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  item.parentName!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                    color: Color(0xff94a3b8),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff1f5f9),
                                          border: Border.all(color: const Color(0xffe5e7eb)),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${item.remainingTotal}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(open ? Icons.expand_less : Icons.expand_more),
                                    ],
                                  ),
                                ),
                              ),
                              if (open)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(64, 0, 12, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ödənişsiz elan — ${item.freeRemaining} elan',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Ödənişli elan — ${item.paidRemaining} elan',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: Color(0xffef4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
      ),
    );
  }
}