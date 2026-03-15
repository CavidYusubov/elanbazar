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
      backgroundColor: const Color(0xfff3f4f6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
                SliverToBoxAdapter(child: _buildHeader(st)),
                SliverToBoxAdapter(child: _buildMeta(st)),
                SliverToBoxAdapter(child: _buildToggle(st)),
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

  Widget _buildHeader(UserProfileState st) {
    final user = st.user ?? {};
    final stats = st.stats ?? {};

    final photo = user['photo_url']?.toString() ?? '';
    final name = user['name']?.toString() ?? '';
    final city = user['city']?.toString() ?? '';
    final isOnline = user['is_online'] == true;
    final followers = (stats['followers'] ?? 0).toString();
    final following = (stats['following'] ?? 0).toString();
    final store = user['store'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty ? const Icon(Icons.person, size: 42) : null,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            if (city.isNotEmpty || isOnline)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (city.isNotEmpty)
                    Text(
                      city,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  if (city.isNotEmpty && isOnline)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('•', style: TextStyle(color: Colors.black38)),
                    ),
                  if (isOnline)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Online',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _miniStat(followers, 'izləyici'),
                const SizedBox(width: 18),
                _miniStat(following, 'izləyir'),
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
                      padding: const EdgeInsets.symmetric(vertical: 13),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Mesaj göndər',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            if (store is Map) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        store['name']?.toString() ?? 'Mağaza',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildMeta(UserProfileState st) {
    final user = st.user ?? {};
    final memberSince = user['member_since']?.toString() ?? '';
    final phoneVerified = user['phone_verified'] == true;

    if (memberSince.isEmpty && !phoneVerified) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            if (memberSince.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.black54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('$memberSince tarixindən platformadadır'),
                  ),
                ],
              ),
            if (memberSince.isNotEmpty && phoneVerified)
              const SizedBox(height: 12),
            if (phoneVerified)
              Row(
                children: const [
                  Icon(Icons.verified_user, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Telefon nömrəsi təsdiqlənib'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(UserProfileState st) {
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