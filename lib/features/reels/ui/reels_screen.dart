import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elanbazar/features/comments/ui/comments_sheet.dart';
import 'package:elanbazar/features/favorites/state/favorites_controller.dart';
import 'package:elanbazar/features/profile/store_profile_screen.dart';
import 'package:elanbazar/features/profile/user_profile_screen.dart';
import 'package:elanbazar/features/shell/ui/main_shell.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/auth_screen.dart';
import '../../ad_create/ui/ad_create_screen.dart';
import '../../favorites/ui/favorites_screen.dart';
import '../../messages/ui/messages_list_screen.dart';
import '../../profile/ui/account_screen.dart';
import '../../ads_detail/ui/ad_detail_screen.dart';
import '../state/reels_controller.dart';
import '../../store/ui/store_create_screen.dart';
import '../../store/ui/store_dashboard_screen.dart';
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

  Future<void> _openCommentsSheet(BuildContext context, int adId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => CommentsSheet(adId: adId),
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
            child: _SideMenuPanel(),
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
                                  'Bütün elanlar',
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
                          onComment: () => _openCommentsSheet(context, ad.id),
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

enum _SideInnerPanel { main, contact, lang, help }

class _SideMenuPanel extends ConsumerStatefulWidget {
  _SideMenuPanel({super.key});

  @override
  ConsumerState<_SideMenuPanel> createState() => _SideMenuPanelState();
}

class _SideMenuPanelState extends ConsumerState<_SideMenuPanel> {
  bool dark = true;
  _SideInnerPanel panel = _SideInnerPanel.main;

  void _goMain() {
    setState(() => panel = _SideInnerPanel.main);
  }

  void _openPanel(_SideInnerPanel next) {
    setState(() => panel = next);
  }

  void _closeMenu() {
    Navigator.of(context).pop();
  }

  void _push(Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _replaceShell({
    required int index,
    HomeTopTab homeTab = HomeTopTab.reels,
  }) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainShell(
          initialIndex: index,
          initialHomeTab: homeTab,
        ),
      ),
    );
  }

  void _openLogin() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    final user = auth.user;
    final isLoggedIn = user != null;

    final userStore = user?.store;
    final hasStore = userStore != null;

    final userName = user?.name ?? 'Xoş gəldiniz!';
    final userPhone = user?.phone ?? 'Daxil olmaq üçün toxunun';
    final userAvatar = user?.photoUrl;
    final profileId = user != null
        ? user.id.toString().padLeft(7, '0')
        : null;

    final width = MediaQuery.of(context).size.width * 0.84;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: width,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              bottomLeft: Radius.circular(22),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 24,
                offset: Offset(-4, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: switch (panel) {
                    _SideInnerPanel.main => _buildMainPanel(
                        isLoggedIn: isLoggedIn,
                        userName: userName,
                        userPhone: userPhone,
                        profileId: profileId,
                        userAvatar: userAvatar,
                        hasStore: hasStore,
                        storeStatus: userStore?.status,
                      ),
                    _SideInnerPanel.contact => _buildContactPanel(),
                    _SideInnerPanel.lang => _buildLangPanel(),
                    _SideInnerPanel.help => _buildHelpPanel(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainPanel({
    required bool isLoggedIn,
    required String userName,
    required String userPhone,
    required String? profileId,
    required String? userAvatar,
    required bool hasStore,
    required String? storeStatus,
  }) {
    return Column(
      key: const ValueKey('main'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: isLoggedIn
                      ? () {
                          _closeMenu();
                          _push(const AccountScreen());
                        }
                      : _openLogin,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        _buildAvatar(userAvatar),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLoggedIn ? userName : 'Xoş gəldiniz!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isLoggedIn ? 'Xoş gəldiniz!' : 'Daxil olmaq üçün toxunun',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isLoggedIn && profileId != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Profil nömrəsi: $profileId',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _closeMenu,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            children: [
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
                onTap: () => _push(const AdCreateScreen()),
              ),

              if (isLoggedIn) ...[
                _menuRow(
                  icon: Icons.dashboard_outlined,
                  title: 'İdarə paneli',
                  onTap: () => _push(const AccountScreen()),
                ),

                _menuRow(
                  icon: Icons.person_outline,
                  title: 'Profilim',
                  onTap: () => _push(const AccountScreen()),
                ),

                if (hasStore)
                  _menuRow(
                    icon: (storeStatus == 'approved' || storeStatus == 'active')
                        ? Icons.storefront_outlined
                        : Icons.hourglass_bottom_outlined,
                    title: (storeStatus == 'approved' || storeStatus == 'active')
                        ? 'Mağaza paneli'
                        : 'Mağaza: təsdiq gözləyir',
                    onTap: () {
                        _closeMenu();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StoreDashboardScreen(),
                          ),
                        );
                      },
                  )
                else
                  _menuRow(
                    icon: Icons.store_mall_directory_outlined,
                    title: 'Mağaza yaradın',
                    onTap: () {
                      _closeMenu();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StoreCreateScreen(),
                        ),
                      );
                    },
                  ),

                _menuRow(
                  icon: Icons.favorite_border,
                  title: 'Seçilmişlər',
                  onTap: () => _push(const FavoritesScreen()),
                ),

                _menuRow(
                  icon: Icons.chat_bubble_outline,
                  title: 'Mesajlar',
                  onTap: () => _push(const MessagesListScreen()),
                ),

                _menuRow(
                  icon: Icons.notifications_none,
                  title: 'Bildirişlər',
                  onTap: () {
                    _closeMenu();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bildirişlər hissəsini sonra bağlayacağıq')),
                    );
                  },
                ),
              ],

              _menuRow(
                icon: Icons.help_outline,
                title: 'Tez-tez verilən suallar',
                onTap: () {
                  _closeMenu();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('FAQ hissəsini sonra qoşacağıq')),
                  );
                },
              ),

              _menuRow(
                icon: Icons.language,
                title: 'Dil seçin',
                onTap: () => _openPanel(_SideInnerPanel.lang),
              ),

              _menuRow(
                icon: Icons.info_outline,
                title: 'Kömək edin',
                onTap: () => _openPanel(_SideInnerPanel.help),
              ),

              _menuRow(
                icon: Icons.mail_outline,
                title: 'Bizimlə əlaqə saxlayın',
                onTap: () => _openPanel(_SideInnerPanel.contact),
              ),

              const SizedBox(height: 12),

              if (isLoggedIn)
                _menuRow(
                  icon: Icons.logout,
                  title: 'Çıxış',
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                )
              else
                _menuRow(
                  icon: Icons.login,
                  title: 'Daxil ol',
                  onTap: _openLogin,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactPanel() {
    return _InnerPanelScaffold(
      key: const ValueKey('contact'),
      title: 'Əlaqə vasitələri',
      onBack: _goMain,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        children: [
          _menuRow(
            icon: Icons.phone_outlined,
            title: 'Zəng et',
            onTap: () {},
          ),
          _menuRow(
            icon: Icons.email_outlined,
            title: 'Məktub yaz',
            onTap: () {},
          ),
          _menuRow(
            icon: Icons.facebook,
            title: 'Facebook',
            onTap: () {},
          ),
          _menuRow(
            icon: Icons.camera_alt_outlined,
            title: 'Instagram',
            onTap: () {},
          ),
          _menuRow(
            icon: Icons.music_note_outlined,
            title: 'TikTok',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLangPanel() {
    return _InnerPanelScaffold(
      key: const ValueKey('lang'),
      title: 'Dil seçin',
      onBack: _goMain,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        children: [
          _langRow('🇦🇿', 'Azərbaycan'),
          _langRow('🇷🇺', 'Rus'),
          _langRow('🇬🇧', 'İngilis'),
        ],
      ),
    );
  }

  Widget _buildHelpPanel() {
    return _InnerPanelScaffold(
      key: const ValueKey('help'),
      title: 'Kömək edin',
      onBack: _goMain,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        children: [
          _textOnlyRow('Qaydalar və Şərtlər'),
          _textOnlyRow('Məxfilik Siyasəti'),
          _textOnlyRow('Hüquqi Bildiriş'),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    final hasImage = url != null && url.isNotEmpty;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(Icons.person, color: Colors.black45);
              },
            )
          : const Icon(Icons.person, color: Colors.black45),
    );
  }

  Widget _langRow(String flag, String title) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textOnlyRow(String title) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 14.5,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _InnerPanelScaffold extends StatelessWidget {
  const _InnerPanelScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
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