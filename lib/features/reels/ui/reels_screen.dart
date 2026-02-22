import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/reels_controller.dart';
import '../../ads_detail/ui/ad_detail_screen.dart';
import 'package:elanbazar/features/discover/ui/discover_screen.dart';
import 'package:elanbazar/features/profile/user_profile_screen.dart';
import 'package:elanbazar/features/profile/store_profile_screen.dart';
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  late final PageController _page;

  @override
  void initState() {
    super.initState();
    _page = PageController();
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    if (!_page.hasClients) return;
    _page.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(reelsControllerProvider);

    if (st.loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _page,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) {
          final ad = st.items[i];
          ref.read(reelsControllerProvider.notifier).markSeen(ad.id);
          ref.read(reelsControllerProvider.notifier).ensureMore(i);
        },
        itemCount: st.items.length,
        itemBuilder: (context, i) {
          final ad = st.items[i];
          final next3 = st.items.skip(i + 1).take(3).toList();

          return Stack(
            fit: StackFit.expand,
            children: [
              // BG image
              Image.network(
                ad.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white24, size: 48),
                  ),
                ),
              ),

Positioned.fill(
  child: LayoutBuilder(
    builder: (context, c) {
      const topSafeHeight = 120.0;    
      const bottomSafeHeight = 320.0; 

      return Column(
        children: [
          // top: klik udmasın
          SizedBox(height: topSafeHeight, child: const IgnorePointer(ignoring: true, child: SizedBox.expand())),

          // middle: tap => detail
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdDetailScreen(adId: ad.id),
                    ),
                  );
                },
              ),
            ),
          ),

          // bottom: klik udmasın (next3 işləsin)
          SizedBox(height: bottomSafeHeight, child: const IgnorePointer(ignoring: true, child: SizedBox.expand())),
        ],
      );
    },
  ),
),

              // ✅ TikTok kimi top toggle (yuxarıdan ~20px aşağı)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 14, right: 14),
                  child: Row(
                    children: [
                      _chip('Reels', active: true),
                      const SizedBox(width: 8),
_chip('Kəşf et', active: false, onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const DiscoverScreen()),
  );
}),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              // Right actions
              Positioned(
                right: 12,
                top: 130,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final pub = ad.publisher;
                        if (pub != null) {
                          if (pub.type == 'user') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => UserProfileScreen(userId: pub.id)),
                            );
                          } else if (pub.type == 'store') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => StoreProfileScreen(
                                        slug: pub.slug ?? pub.id.toString(),
                                      )),
                            );
                          }
                        }
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white24,
                        backgroundImage: (ad.publisher?.avatarUrl != null &&
                                ad.publisher!.avatarUrl!.isNotEmpty)
                            ? NetworkImage(ad.publisher!.avatarUrl!)
                            : null,
                        child: (ad.publisher?.avatarUrl == null ||
                                ad.publisher!.avatarUrl!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _actionBtn(Icons.favorite_border, '${ad.likeCount}'),
                    const SizedBox(height: 14),
                    _actionBtn(Icons.chat_bubble_outline, '${ad.commentCount}'),
                    const SizedBox(height: 14),
                    _actionBtn(Icons.more_horiz, ''),
                  ],
                ),
              ),

              // Bottom info + next 3
              Positioned(
                left: 14,
                right: 14,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_fmtPrice(ad.price)} ${ad.currency}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ad.city} • ${ad.category}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        shadows: const [Shadow(blurRadius: 10, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Next 3 click -> jump
                    for (int k = 0; k < next3.length; k++)
                      _nextCard(
                        img: next3[k].coverUrl,
                        title: next3[k].title,
                        subtitle: '${next3[k].city} • ${next3[k].category}',
                        onTap: () => _jumpTo(i + 1 + k),
                      ),
                  ],
                ),
              ),

            
            ],
          );
        },
      ),
    );
  }

  static Widget _chip(String text, {required bool active, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.20) : Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }

  static Widget _actionBtn(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ]
      ],
    );
  }

  static Widget _nextCard({
    required String img,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.58),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  img,
                  width: 92,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 92,
                    height: 72,
                    color: Colors.white10,
                    child: const Icon(Icons.image, color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtPrice(double v) => (v % 1 == 0) ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}