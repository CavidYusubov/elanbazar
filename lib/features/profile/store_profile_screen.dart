import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/store_profile_controller.dart';
import '../discover/ui/ad_card.dart';
import '../ads_detail/ui/ad_detail_screen.dart';

class StoreProfileScreen extends ConsumerStatefulWidget {
  final String slug;
  const StoreProfileScreen({super.key, required this.slug});

  @override
  ConsumerState<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends ConsumerState<StoreProfileScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.maxScrollExtent - pos.pixels < 800) {
      ref.read(storeProfileControllerProvider(widget.slug).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(storeProfileControllerProvider(widget.slug));

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => ref.read(storeProfileControllerProvider(widget.slug).notifier).loadInitial(),
        child: Builder(
          builder: (_) {
            if (st.loading && st.ads.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (st.error != null && st.ads.isEmpty) {
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
                SliverToBoxAdapter(child: _buildHeader(st)),
                SliverToBoxAdapter(child: _buildStats(st)),
                SliverToBoxAdapter(child: _buildDescription(st)),
                SliverToBoxAdapter(child: _buildViewToggle(st)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: st.gridView
                      ? SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.74,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final ad = st.ads[i];
                              return AdCard(
                                title: ad.title,
                                price: ad.priceStr.isNotEmpty ? ad.priceStr : ad.price.toStringAsFixed(0),
                                currency: ad.currency,
                                coverUrl: ad.coverUrl,
                                user: ad.userName,
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
                            childCount: st.ads.length,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final ad = st.ads[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: AdCard(
                                  title: ad.title,
                                  price: ad.priceStr.isNotEmpty ? ad.priceStr : ad.price.toStringAsFixed(0),
                                  currency: ad.currency,
                                  coverUrl: ad.coverUrl,
                                  user: ad.userName,
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
                                ),
                              );
                            },
                            childCount: st.ads.length,
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

  Widget _buildHeader(StoreProfileState st) {
    final cover = st.store?['cover_url']?.toString() ?? '';
    final logo = st.store?['logo_url']?.toString() ?? '';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: cover.isNotEmpty
              ? Image.network(cover, fit: BoxFit.cover)
              : Container(color: Colors.grey.shade300),
        ),
        Positioned(
          top: 40,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Colors.black38,
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          left: 16,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
            child: logo.isEmpty ? const Icon(Icons.store, size: 40) : null,
          ),
        ),
        SizedBox(height: 0),
      ],
    );
  }

  Widget _buildStats(StoreProfileState st) {
    final adsCount = st.store?['ads_count']?.toString() ?? '0';
    final views = st.stats?['views']?.toString() ?? '0';
    final followers = st.stats?['followers']?.toString() ?? '0';
    final name = st.store?['name']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 16), // space below cover and logo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mağazalar • $name', style: const TextStyle(color: Colors.black54)),
          Row(
            children: [
              Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              if (st.store?['is_verified'] == true) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, color: Colors.blue, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem(adsCount, 'Elanlar'),
              _statItem(views, 'Bəyənilib'),
              _statItem(followers, 'İzləyicilər'),
            ],
          ),
          const SizedBox(height: 12),
          Text('Bütün kateqoriyalar • $adsCount elan', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: st.isFollowing ? Colors.grey : Colors.black),
                  onPressed: () {},
                  child: Text(st.isFollowing ? 'İzləyirəm' : 'İzləyirəm', style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.more_horiz),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }

  Widget _buildDescription(StoreProfileState st) {
    final description = st.store?['description']?.toString() ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(description, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  Widget _buildViewToggle(StoreProfileState st) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleButton(
              icon: Icons.grid_view,
              active: st.gridView,
              onTap: () => ref.read(storeProfileControllerProvider(widget.slug).notifier).toggleView(),
            ),
            _toggleButton(
              icon: Icons.list,
              active: !st.gridView,
              onTap: () => ref.read(storeProfileControllerProvider(widget.slug).notifier).toggleView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton({required IconData icon, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 24, color: active ? Colors.black : Colors.grey),
      ),
    );
  }
}
