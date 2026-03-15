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
      backgroundColor: const Color(0xfff3f4f6),
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
                SliverToBoxAdapter(child: _buildDescription(st)),
                SliverToBoxAdapter(child: _buildAddress(st)),
                SliverToBoxAdapter(child: _buildGallery(st)),
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
    final store = st.store ?? {};
    final stats = st.stats ?? {};

    final cover = store['cover_url']?.toString() ?? '';
    final logo = store['logo_url']?.toString() ?? '';
    final name = store['name']?.toString() ?? '';
    final cityName = (store['city'] is Map) ? (store['city']['name']?.toString() ?? '') : '';
    final phone = store['phone']?.toString() ?? '';
    final adsCount = (store['ads_count'] ?? 0).toString();
    final views = (stats['views'] ?? 0).toString();
    final followers = (stats['followers'] ?? 0).toString();
    final isVerified = store['is_verified'] == true;
    final isOpenNow = store['is_open_now'] == true;
    final workFrom = store['work_from']?.toString() ?? '';
    final workTo = store['work_to']?.toString() ?? '';

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: cover.isNotEmpty
                    ? Image.network(cover, fit: BoxFit.cover)
                    : Container(color: Colors.grey.shade300),
              ),
              Positioned(
                top: 44,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
                    child: logo.isEmpty ? const Icon(Icons.store, size: 42) : null,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 54, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Colors.blue, size: 20),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Mağaza',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (cityName.isNotEmpty)
                  Text(
                    cityName,
                    style: const TextStyle(color: Colors.black54),
                  ),
                const SizedBox(height: 10),
                if (workFrom.isNotEmpty && workTo.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'İş saatları: $workFrom - $workTo',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isOpenNow ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOpenNow ? 'Açıqdır' : 'Bağlıdır',
                              style: TextStyle(
                                color: isOpenNow ? Colors.green : Colors.black54,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem(adsCount, 'Elan'),
                    _statItem(views, 'Baxış'),
                    _statItem(followers, 'İzləyici'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: st.isFollowing ? Colors.grey.shade300 : Colors.blue.shade100,
                          foregroundColor: st.isFollowing ? Colors.black : Colors.blue.shade900,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          st.isFollowing ? 'İzlənilir' : '+ İzlə',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.phone, color: Colors.green),
                          label: Text(
                            phone,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDescription(StoreProfileState st) {
    final description = st.store?['description']?.toString() ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          description,
          style: const TextStyle(color: Colors.black87, height: 1.5),
        ),
      ),
    );
  }

  Widget _buildAddress(StoreProfileState st) {
    final address = st.store?['address']?.toString() ?? '';
    if (address.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(StoreProfileState st) {
    final galleryRaw = st.store?['gallery'];
    if (galleryRaw is! List || galleryRaw.isEmpty) {
      return const SizedBox.shrink();
    }

    final gallery = galleryRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => (e['url']?.toString().isNotEmpty ?? false))
        .toList();

    if (gallery.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Qalereya',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final imageUrl = gallery[index]['url']?.toString() ?? '';
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(imageUrl, fit: BoxFit.cover),
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

  Widget _buildViewToggle(StoreProfileState st) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
        ],
      ),
    );
  }

  Widget _toggleButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          icon,
          size: 22,
          color: active ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}