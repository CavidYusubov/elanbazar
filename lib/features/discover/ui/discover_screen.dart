import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/discover_controller.dart';
import '../../ads_detail/ui/ad_detail_screen.dart';
import 'ad_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;

    // son 800px qalanda loadMore
    if (pos.maxScrollExtent - pos.pixels < 800) {
      ref.read(discoverControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(discoverControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.menu),
                ),
                const SizedBox(width: 6),
                const Text(
                  'elanbazar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                _iconSquare(Icons.search, onTap: () {}),
                const SizedBox(width: 10),
                _iconSquare(Icons.tune, onTap: () => _showFilters(context)),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(discoverControllerProvider.notifier).refresh(),
        child: Builder(
          builder: (_) {
            if (st.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (st.error != null && st.items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text('Xəta: ${st.error}')),
                ],
              );
            }

            return CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        _scopeChip('Hamısı', active: st.scope == 'all', onTap: () {
                          ref.read(discoverControllerProvider.notifier).setScope('all');
                        }),
                        const SizedBox(width: 10),
                        _scopeChip('VIP', active: st.scope == 'vip', onTap: () {
                          ref.read(discoverControllerProvider.notifier).setScope('vip');
                        }),
                        const SizedBox(width: 10),
                        _scopeChip('Premium', active: st.scope == 'premium', onTap: () {
                          ref.read(discoverControllerProvider.notifier).setScope('premium');
                        }),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.74,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final ad = st.items[i];
                        return AdCard(
                          title: ad.title,
                          price: ad.priceStr.isNotEmpty ? ad.priceStr : ad.price.toStringAsFixed(0),
                          currency: ad.currency,
                          coverUrl: ad.coverUrl,
                          user: ad.publisher?.name ?? ad.userName,
                          city: ad.cityName,
                          date: ad.dateStr,
                          publisher: ad.publisher,
                          isVip: ad.isVipActive,
                          isPremium: ad.isPremiumActive,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AdDetailScreen(adId: ad.id)),
                            );
                          },
                        );
                      },
                      childCount: st.items.length,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: st.loadingMore
                          ? const CircularProgressIndicator()
                          : (!st.hasMore ? const Text('Son') : const SizedBox.shrink()),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _iconSquare(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon),
      ),
    );
  }

  static Widget _scopeChip(String t, {required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? Colors.black : Colors.black12),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filterlər (sonra bağlayacağıq)', style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 10),
              Text('• şəhər, qiymət aralığı, kateqoriya, sort ...'),
              SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }
}