import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elanbazar/features/favorites/state/favorites_controller.dart';
import 'package:elanbazar/features/profile/store_profile_screen.dart';
import 'package:elanbazar/features/profile/user_profile_screen.dart';
import 'package:elanbazar/features/shell/ui/main_shell.dart';

import '../../ads_detail/ui/ad_detail_screen.dart';
import '../state/reels_controller.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenDiscover;

  const ReelsScreen({
    super.key,
    this.onOpenDiscover,
  });

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

  void _openDetail(BuildContext context, int adId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AdDetailScreen(adId: adId)),
    );
  }

  void _openSideMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'menu',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: const _SideMenuPanel(),
          ),
        );
      },
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
          final isFav = ref.watch(isFavoriteProvider(ad.id));
          final next3 = st.items.skip(i + 1).take(3).toList();

          const rightRailWidth = 55.0;
          final isStore = ad.publisher?.type == 'store';

          return Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      ad.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white24,
                            size: 48,
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 56),
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _openDetail(context, ad.id),
                                  ),
                                ),
                              ),
                              const SizedBox(width: rightRailWidth),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            height: 56,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (isStore)
                                  GestureDetector(
                                    onTap: () {
                                      final pub = ad.publisher;
                                      if (pub != null) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => StoreProfileScreen(
                                              slug: pub.slug ?? pub.id.toString(),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.storefront, color: Colors.white, size: 22),
                                        SizedBox(width: 6),
                                        Text(
                                          'Mağaza',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  const SizedBox(width: 64),

                                const Spacer(),

                                _topTab('Sənin üçün', active: true, onTap: () {}),
                                const SizedBox(width: 14),
                                _topTab(
                                  'Kəşf et',
                                  active: false,
                                  onTap: () {
                                    if (widget.onOpenDiscover != null) {
                                      widget.onOpenDiscover!();
                                      return;
                                    }

                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const MainShell(
                                          initialIndex: 0,
                                          initialHomeTab: HomeTopTab.discover,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const Spacer(),

                                InkWell(
                                  onTap: () => _openSideMenu(context),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.16),
                                      ),
                                    ),
                                    child: const Icon(Icons.menu, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 5,
                      top: 90,
                      child: SizedBox(
                        width: rightRailWidth,
                        child: ReelActions(
                          avatarUrl: ad.publisher?.avatarUrl,
                          likeCount: ad.likeCount,
                          commentCount: ad.commentCount,
                          isFavorite: isFav,
                          onAvatarTap: () {
                            final pub = ad.publisher;
                            if (pub != null) {
                              if (pub.type == 'user') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => UserProfileScreen(userId: pub.id),
                                  ),
                                );
                              } else if (pub.type == 'store') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StoreProfileScreen(
                                      slug: pub.slug ?? pub.id.toString(),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          onLike: () async {
                            await ref.read(favoritesControllerProvider.notifier).toggle(ad.id);
                          },
                          onComment: () {},
                          onMore: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ad.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_fmtPrice(ad.price)} ${ad.currency}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ad.city} • ${ad.category}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        shadows: const [Shadow(blurRadius: 10, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 12),
                    NextCards(
                      items: next3,
                      onTap: (adId) {
                        final idx = st.items.indexWhere((x) => x.id == adId);
                        if (idx != -1) _jumpTo(idx);
                      },
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

  static Widget _topTab(
    String text, {
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.75),
          fontWeight: active ? FontWeight.w800 : FontWeight.w700,
          fontSize: active ? 18 : 16,
          shadows: const [Shadow(blurRadius: 10, color: Colors.black54)],
        ),
      ),
    );
  }

  static String _fmtPrice(double v) =>
      (v % 1 == 0) ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}

class _SideMenuPanel extends StatefulWidget {
  const _SideMenuPanel();

  @override
  State<_SideMenuPanel> createState() => _SideMenuPanelState();
}

class _SideMenuPanelState extends State<_SideMenuPanel> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.82;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: w,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Xoş gəldiniz!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('Daxil olmaq üçün toxunun', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _menuRow(
                  icon: Icons.nightlight_outlined,
                  title: 'Qaranlıq rejim',
                  trailing: Switch(
                    value: dark,
                    onChanged: (v) => setState(() => dark = v),
                  ),
                  onTap: () => setState(() => dark = !dark),
                ),
                _menuRow(
                  icon: Icons.add_box_outlined,
                  title: 'Elan yerləşdirin',
                  onTap: () {},
                ),
                _menuRow(
                  icon: Icons.help_outline,
                  title: 'Tez-tez verilən suallar',
                  onTap: () {},
                ),
                _menuRow(
                  icon: Icons.language,
                  title: 'Dil seçin',
                  onTap: () {},
                ),
                _menuRow(
                  icon: Icons.info_outline,
                  title: 'Kömək edin',
                  onTap: () {},
                ),
                _menuRow(
                  icon: Icons.mail_outline,
                  title: 'Bizimlə əlaqə saxlayın',
                  onTap: () {},
                ),
                const Spacer(),
                _menuRow(
                  icon: Icons.login,
                  title: 'Daxil ol',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ...[trailing].whereType<Widget>(),
          ],
        ),
      ),
    );
  }
}

class ReelActions extends StatelessWidget {
  const ReelActions({
    super.key,
    required this.onAvatarTap,
    required this.onLike,
    required this.onComment,
    required this.onMore,
    required this.avatarUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isFavorite,
  });

  final VoidCallback onAvatarTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onMore;
  final String? avatarUrl;
  final int likeCount;
  final int commentCount;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 18),
        _btn(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          '$likeCount',
          onLike,
          color: isFavorite ? Colors.red : Colors.white,
        ),
        const SizedBox(height: 14),
        _btn(Icons.chat_bubble_outline, '$commentCount', onComment),
        const SizedBox(height: 14),
        _btn(Icons.more_horiz, '', onMore),
      ],
    );
  }

  Widget _btn(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NextCards extends StatelessWidget {
  const NextCards({super.key, required this.items, required this.onTap});

  final List<dynamic> items;
  final void Function(int adId) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.map((e) {
        final int id = e.id;
        final String coverUrl = e.coverUrl;
        final String title = e.title;
        final String subtitle = '${e.city} • ${e.category}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onTap(id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      coverUrl,
                      width: 92,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
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
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}