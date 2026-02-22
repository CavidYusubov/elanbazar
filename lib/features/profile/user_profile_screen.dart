import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/user_profile_controller.dart';
import '../ads_detail/ui/ad_detail_screen.dart';

import '../discover/ui/ad_card.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final int userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
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
      ref.read(userProfileControllerProvider(widget.userId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(userProfileControllerProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(st.user?['name']?.toString() ?? 'Profil'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(userProfileControllerProvider(widget.userId).notifier).loadInitial(),
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
                SliverToBoxAdapter(
                  child: _buildHeader(context, st),
                ),
                SliverToBoxAdapter(
                  child: _buildToggle(st),
                ),
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

  Widget _buildHeader(BuildContext context, UserProfileState st) {
    final photo = st.user?['photo']?.toString();
    final name = st.user?['name']?.toString() ?? '';
    final following = st.stats?['following'] ?? 0;
    final followers = st.stats?['followers'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: (photo != null && photo.isNotEmpty) ? NetworkImage(photo) : null,
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star, color: Colors.amber, size: 20),
              Icon(Icons.star_half, color: Colors.amber, size: 20),
            ],
          ),
          const SizedBox(height: 2),
          const Text('Satıcı', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {},
            child: const Text('Mesaj göndər', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${followers.toString()} izləyici'),
              const SizedBox(width: 12),
              Text('${following.toString()} izləyir'),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildToggle(UserProfileState st) {
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
              onTap: () => ref.read(userProfileControllerProvider(widget.userId).notifier).toggleView(),
            ),
            _toggleButton(
              icon: Icons.list,
              active: !st.gridView,
              onTap: () => ref.read(userProfileControllerProvider(widget.userId).notifier).toggleView(),
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
