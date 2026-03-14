import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ad_create/ui/ad_create_screen.dart';
import '../models/store_models.dart';
import '../state/store_dashboard_controller.dart';
import '../../profile/store_profile_screen.dart';
import 'store_edit_screen.dart';
class StoreDashboardScreen extends ConsumerStatefulWidget {
  const StoreDashboardScreen({super.key});

  @override
  ConsumerState<StoreDashboardScreen> createState() =>
      _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends ConsumerState<StoreDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(storeDashboardControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(storeDashboardControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Mağaza paneli'),
        elevation: 0,
      ),
      body: SafeArea(
        child: st.loading && st.store == null
            ? const Center(child: CircularProgressIndicator())
            : st.store == null
                ? _DashboardError(
                    text: st.error ?? 'Məlumat tapılmadı',
                    onRetry: () {
                      ref.read(storeDashboardControllerProvider.notifier).load();
                    },
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(storeDashboardControllerProvider.notifier).load(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 40),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 960),
                            child: _DashboardCard(store: st.store!),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.store});

  final StoreDashboard store;

  @override
  Widget build(BuildContext context) {
    final badge = _badgeColors(store.statusUi);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mağaza paneli',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: badge.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  store.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badge.fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StoreLogo(url: store.logoUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        store.city?.name,
                        store.address,
                      ].where((e) => (e ?? '').trim().isNotEmpty).join(' · '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if ((store.messages.pending ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        store.messages.pending!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                    if ((store.messages.rejected ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        store.messages.rejected!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                            onPressed: () {
                                Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => StoreProfileScreen(slug: store.slug),
                                ),
                                );
                            },
                            child: const Text('Mağaza səhifəsinə bax'),
                            ),
                            OutlinedButton(
                            onPressed: () {
                                Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const StoreEditScreen(),
                                ),
                                );
                            },
                            child: const Text('Mağazanı düzəliş et'),
                            ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdCreateScreen(),
                              ),
                            );
                          },
                          child: const Text('Yeni elan yerləşdir'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: MediaQuery.of(context).size.width < 768 ? 2 : 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                label: 'Elan sayı',
                value: '${store.adsCount}',
              ),
              _StatCard(
                label: 'Reytinq',
                value: store.rating.toStringAsFixed(1),
              ),
              _StatCard(
                label: 'Status',
                value: _cap(store.status),
                small: true,
              ),
              _StatCard(
                label: 'Təsdiqlənmə',
                value: store.isVerified ? 'Bəli' : 'Xeyr',
                small: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static ({Color bg, Color fg}) _badgeColors(String ui) {
    switch (ui) {
      case 'ok':
        return (bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534));
      case 'rejected':
        return (bg: const Color(0xFFFEE2E2), fg: const Color(0xFF991B1B));
      default:
        return (bg: const Color(0xFFFEF9C3), fg: const Color(0xFF92400E));
    }
  }

  static String _cap(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _StoreLogo extends StatelessWidget {
  const _StoreLogo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasImage = (url ?? '').trim().isNotEmpty;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.storefront,
                  size: 26,
                  color: Color(0xFF6B7280),
                );
              },
            )
          : const Icon(
              Icons.storefront,
              size: 26,
              color: Color(0xFF6B7280),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.small = false,
  });

  final String label;
  final String value;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: small ? 13 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
    required this.text,
    required this.onRetry,
  });

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_mall_directory_outlined, size: 42),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Yenidən yoxla'),
            ),
          ],
        ),
      ),
    );
  }
}