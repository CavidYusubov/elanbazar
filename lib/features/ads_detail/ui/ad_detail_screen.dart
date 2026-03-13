import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/ad_detail_provider.dart';
import '../models/ad_detail.dart';
import '../state/ad_similar_provider.dart';
import '../models/similar_ad.dart';

import '../../profile/user_profile_screen.dart';
import '../../profile/store_profile_screen.dart';
import '../../favorites/state/favorites_controller.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/auth_screen.dart';
import '../../messages/ui/message_thread_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _DT {
  static const bg = Color(0xFF080A0F);
  static const surface = Color(0xFF111318);
  static const card = Color(0xFF191C24);
  static const cardBorder = Color(0xFF272B36);
  static const gold = Color(0xFFF5B731);
  static const goldLight = Color(0xFFFFD97A);
  static const accent = Color(0xFFFF5C2B);
  static const green = Color(0xFF1EDB8A);
  static const blue = Color(0xFF3B7EFF);
  static const textHi = Color(0xFFF8F9FA);
  static const textMid = Color(0xFF9BA3B2);
  static const textLow = Color(0xFF4A5060);

  static TextStyle syne({
    double s = 14,
    FontWeight w = FontWeight.w700,
    Color c = textHi,
  }) =>
      TextStyle(fontSize: s, fontWeight: w, color: c);

  static TextStyle dm({
    double s = 14,
    FontWeight w = FontWeight.w400,
    Color c = textMid,
  }) =>
      TextStyle(fontSize: s, fontWeight: w, color: c, height: 1.5);
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class AdDetailScreen extends ConsumerStatefulWidget {
  const AdDetailScreen({super.key, required this.adId});
  final int adId;

  @override
  ConsumerState<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends ConsumerState<AdDetailScreen>
    with TickerProviderStateMixin {
  final PageController _page = PageController(viewportFraction: 1);
  final ScrollController _scroll = ScrollController();

  int _imgIndex = 0;
  bool _descExpanded = false;
  double _scrollOffset = 0;
  late AnimationController _priceAnim;
  late AnimationController _fadeAnim;

  @override
  void initState() {
    super.initState();
    _priceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scroll.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scroll.offset);
      }
    });
  }

  @override
  void dispose() {
    _page.dispose();
    _scroll.dispose();
    _priceAnim.dispose();
    _fadeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adDetailProvider(widget.adId));
    final isFav = ref.watch(isFavoriteProvider(widget.adId));

    return async.when(
      loading: () => _LoadingScreen(),
      error: (e, _) => _ErrorScreen(error: e),
      data: (AdDetail ad) => _buildData(ad, isFav),
    );
  }

  Widget _buildData(AdDetail ad, bool isFav) {
    final gallery = ad.galleryUrls;
    final phone = _resolveSellerPhone(ad);
    final isStore = ad.store != null;
    final sellerName = ad.store?.name ?? ad.user?.name ?? 'İstifadəçi';
    final avatarUrl = _resolveSellerAvatar(ad);
    final storeOpenNow = _resolveStoreOpen(ad);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: _DT.bg,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _FullScreenGallery(
                  gallery: gallery,
                  pageController: _page,
                  currentIndex: _imgIndex,
                  isFav: isFav,
                  scrollOffset: _scrollOffset,
                  onPageChanged: (i) => setState(() => _imgIndex = i),
                  onBack: () => Navigator.maybePop(context),
                  onShare: () => _shareAd(ad),
                  onFav: () => ref
                      .read(favoritesControllerProvider.notifier)
                      .toggle(widget.adId),
                  onOpenGallery: () => _openGallery(gallery),
                ),
              ),
              SliverToBoxAdapter(
                child: _PriceTitleCard(ad: ad, priceAnim: _priceAnim),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: _PromoRow(
                    onTap: (s) => _openPaymentSheet(context, service: s),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _SpecsSection(ad: ad),
              ),
              if (_stringMeta(ad, 'vin').isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _VinSection(
                      vin: _stringMeta(ad, 'vin'),
                      onCopy: () async {
                        await Clipboard.setData(
                          ClipboardData(text: _stringMeta(ad, 'vin')),
                        );
                        if (!mounted) return;
                        _toast('VIN kopyalandı');
                      },
                    ),
                  ),
                ),
              if ((ad.description ?? '').trim().isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _DescSection(
                      text: ad.description!,
                      expanded: _descExpanded,
                      onToggle: () =>
                          setState(() => _descExpanded = !_descExpanded),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SellerCard(
                    ad: ad,
                    sellerName: sellerName,
                    avatarUrl: avatarUrl,
                    isStore: isStore,
                    isOpen: storeOpenNow,
                    isVerified: _isSellerVerified(ad),
                    workHours: _resolveWorkHours(ad),
                    phone: phone,
                    onOpenSeller: () => _openSeller(ad),
                    onCall: phone.isEmpty ? null : () => _showPhoneSheet(phone),
                    onMessage: () => _handleMessageTap(ad),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _AdMetaSection(
                    ad: ad,
                    onComplaint: () => _openComplaint(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                  child: _SimilarSection(adId: ad.id),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _FloatingBar(
              phone: phone,
              avatarUrl: avatarUrl,
              onCall: phone.isEmpty ? null : () => _showPhoneSheet(phone),
              onMessage: () => _handleMessageTap(ad),
              onAvatar: () => _openSeller(ad),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMessageTap(AdDetail ad) async {
    final auth = ref.read(authControllerProvider);
    if (auth.user == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (!mounted) return;
    }

    final afterAuth = ref.read(authControllerProvider);
    if (afterAuth.user == null) {
      _toast('Mesaj yazmaq üçün daxil olun');
      return;
    }

    final pid = ad.user?.id;
    if (pid == null) {
      _toast('İstifadəçi tapılmadı');
      return;
    }

    if (afterAuth.user?.id == pid) {
      _toast('Bu sizin öz elanınızdır');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageThreadScreen(partnerId: pid, adId: ad.id),
      ),
    );
  }

  void _openSeller(AdDetail ad) {
    if (ad.store != null && ad.store!.slug.trim().isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StoreProfileScreen(slug: ad.store!.slug.trim()),
        ),
      );
      return;
    }

    if (ad.user != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(userId: ad.user!.id),
        ),
      );
      return;
    }

    _toast('Profil tapılmadı');
  }

  Future<void> _shareAd(AdDetail ad) async {
    await Clipboard.setData(
      ClipboardData(text: '${ad.title} - ${_priceText(ad)} ${ad.currency}'),
    );
    if (!mounted) return;
    _toast('Kopyalandı');
  }

  void _openGallery(List<String> gallery) {
    if (gallery.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: _LightboxDialog(
            gallery: gallery,
            initialIndex: _imgIndex,
          ),
        ),
      ),
    );
  }

  String _resolveSellerPhone(AdDetail ad) {
    final s = ad.store?.phone?.trim();
    if (s != null && s.isNotEmpty) return s;
    return ad.user?.phone?.trim() ?? '';
  }

  bool? _resolveStoreOpen(AdDetail ad) {
    return ad.store?.isOpenNow;
  }

  String? _resolveSellerAvatar(AdDetail ad) {
    try {
      final d = ad.store;
      if (d != null) {
        final v = (d as dynamic).logoUrl;
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    } catch (_) {}

    try {
      final u = ad.user;
      if (u != null) {
        final v = (u as dynamic).photoUrl;
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    } catch (_) {}

    return null;
  }

  bool _isSellerVerified(AdDetail ad) {
    try {
      final v = (ad.store as dynamic?)?.isVerified;
      if (v is bool) return v;
    } catch (_) {}

    try {
      final v = (ad.user as dynamic?)?.isVerified;
      if (v is bool) return v;
    } catch (_) {}

    return false;
  }

  String? _resolveWorkHours(AdDetail ad) {
    try {
      final s = ad.store as dynamic?;
      if (s == null) return null;
      final f = s.workFrom?.toString();
      final t = s.workTo?.toString();
      if (f != null && f.isNotEmpty && t != null && t.isNotEmpty) {
        return '$f – $t';
      }
    } catch (_) {}
    return null;
  }

  bool _boolMeta(AdDetail ad, String key) {
    try {
      final m = (ad as dynamic).meta;
      if (m is Map && m.containsKey(key)) {
        final v = m[key];
        if (v is bool) return v;
        if (v is num) return v != 0;
        if (v is String) {
          final s = v.trim().toLowerCase();
          return s == '1' || s == 'true';
        }
      }
    } catch (_) {}
    return false;
  }

  String _stringMeta(AdDetail ad, String key) {
    try {
      final m = (ad as dynamic).meta;
      if (m is Map && m.containsKey(key) && m[key] != null) {
        return m[key].toString().trim();
      }
    } catch (_) {}
    return '';
  }

  static String _priceText(AdDetail ad) {
    final ps = (ad.priceStr ?? '').trim();
    if (ps.isNotEmpty) {
      final n = double.tryParse(ps);
      if (n != null) {
        return n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
      }
      return ps;
    }

    final p = ad.price;
    if (p == null) return '';
    return p % 1 == 0 ? p.toStringAsFixed(0) : p.toStringAsFixed(2);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: _DT.dm(c: _DT.textHi)),
        backgroundColor: _DT.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showPhoneSheet(String phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _DT.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _PhoneSheet(
        phone: phone,
        onCopy: () async {
          await Clipboard.setData(ClipboardData(text: phone));
          if (!mounted) return;
          Navigator.pop(context);
          _toast('Nömrə kopyalandı');
        },
      ),
    );
  }

  void _openComplaint(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _DT.card,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        final reasons = [
          'Artıq satılıb',
          'Dələduz',
          'Yanlış kontaktlar',
          'Yanlış qiymət',
          'Saxta elan',
          'Yanlış şəkillər',
          'Digər',
        ];

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Şikayətin səbəbi',
                  style: _DT.syne(s: 18, w: FontWeight.w800),
                ),
              ),
              for (final r in reasons)
                ListTile(
                  title: Text(
                    r,
                    style: _DT.dm(c: _DT.textHi, w: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: _DT.textLow,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _toast('Şikayət qəbul edildi');
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _openPaymentSheet(BuildContext context, {required String service}) {
    final cfg = _paymentConfig(service);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _DT.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => _PaymentSheet(cfg: cfg),
    );
  }

  _PayCfg _paymentConfig(String s) {
    switch (s) {
      case 'discover':
        return const _PayCfg(
          title: 'İrəli çək',
          icon: Icons.auto_awesome,
          colors: [Color(0xFF1EDB8A), Color(0xFF0EAA6A)],
          durations: [
            _PayDur(1, 0.50),
            _PayDur(3, 1.20),
            _PayDur(7, 2.20),
          ],
          infoSub: 'Axtarışda yuxarı çıxın. Daha çox baxış.',
        );
      case 'premium':
        return const _PayCfg(
          title: 'Premium',
          icon: Icons.workspace_premium_rounded,
          colors: [Color(0xFFFF5C2B), Color(0xFFE63900)],
          durations: [
            _PayDur(5, 3.50),
            _PayDur(15, 8.90),
            _PayDur(30, 14.90),
          ],
          infoSub: 'Premium elanlar 3x daha çox baxış toplayır.',
        );
      default:
        return const _PayCfg(
          title: 'VIP',
          icon: Icons.bolt_rounded,
          colors: [Color(0xFFF5B731), Color(0xFFD49500)],
          durations: [
            _PayDur(5, 2.55),
            _PayDur(15, 6.38),
            _PayDur(30, 10.63),
          ],
          infoSub: 'VIP elanlar ən önə çıxır.',
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FULL SCREEN GALLERY
// ─────────────────────────────────────────────────────────────────────────────
class _FullScreenGallery extends StatelessWidget {
  const _FullScreenGallery({
    required this.gallery,
    required this.pageController,
    required this.currentIndex,
    required this.isFav,
    required this.scrollOffset,
    required this.onPageChanged,
    required this.onBack,
    required this.onShare,
    required this.onFav,
    required this.onOpenGallery,
  });

  final List<String> gallery;
  final PageController pageController;
  final int currentIndex;
  final bool isFav;
  final double scrollOffset;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onFav;
  final VoidCallback onOpenGallery;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.68;
    final parallax = (scrollOffset * 0.18).clamp(0.0, 40.0);

    return SizedBox(
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: Transform.translate(
              offset: Offset(0, -parallax),
              child: SizedBox(
                height: h + parallax,
                child: PageView.builder(
                  controller: pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: gallery.isEmpty ? 1 : gallery.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (_, i) {
                    final url = gallery.isEmpty ? '' : gallery[i];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: url.isEmpty ? null : onOpenGallery,
                      child: _HeroImage(url: url),
                    );
                  },
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
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.14),
                      Colors.black.withOpacity(0.02),
                      _DT.bg.withOpacity(0.52),
                      _DT.bg,
                    ],
                    stops: const [0.0, 0.28, 0.74, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  children: [
                    _GBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: onBack,
                    ),
                    const Spacer(),
                    _GBtn(
                      icon: Icons.ios_share_rounded,
                      onTap: onShare,
                    ),
                    const SizedBox(width: 10),
                    _GBtn(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      onTap: onFav,
                      accent: isFav ? const Color(0xFFFF3B5C) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (gallery.length > 1)
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    math.min(gallery.length, 8),
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == currentIndex ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == currentIndex
                            ? _DT.gold
                            : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            top: 100,
            right: 14,
            child: _GlassPill(
              child: Text(
                '${gallery.isEmpty ? 0 : currentIndex + 1}/${gallery.length}',
                style: _DT.syne(s: 11, c: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        color: _DT.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 72,
          color: _DT.textLow,
        ),
      );
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Image.network(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: _DT.gold,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return Container(
            color: _DT.surface,
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              color: _DT.textLow,
              size: 64,
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRICE + TITLE
// ─────────────────────────────────────────────────────────────────────────────
class _PriceTitleCard extends StatelessWidget {
  const _PriceTitleCard({required this.ad, required this.priceAnim});

  final AdDetail ad;
  final AnimationController priceAnim;

  static String _priceText(AdDetail ad) {
    final ps = (ad.priceStr ?? '').trim();
    if (ps.isNotEmpty) {
      final n = double.tryParse(ps);
      if (n != null) {
        return n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
      }
      return ps;
    }

    final p = ad.price;
    if (p == null) return '—';
    return p % 1 == 0 ? p.toStringAsFixed(0) : p.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Container(
        decoration: const BoxDecoration(
          color: _DT.bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BadgeRow(ad: ad),
              const SizedBox(height: 18),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: priceAnim,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: priceAnim,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _priceText(ad),
                        style: const TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: _DT.gold,
                          letterSpacing: -2,
                          height: 0.9,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ad.currency,
                        style: _DT.syne(s: 18, c: _DT.textMid),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ad.title,
                style: _DT.syne(s: 22, w: FontWeight.w700, c: _DT.textHi),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (ad.city != null) ...[
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: _DT.textMid,
                    ),
                    const SizedBox(width: 4),
                    Text(ad.city!.name, style: _DT.dm(s: 13)),
                    const SizedBox(width: 14),
                  ],
                  const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 14,
                    color: _DT.textMid,
                  ),
                  const SizedBox(width: 4),
                  Text('${ad.viewsCount} baxış', style: _DT.dm(s: 13)),
                  const SizedBox(width: 14),
                  Text('№${ad.id}', style: _DT.dm(s: 13, c: _DT.textLow)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGES
// ─────────────────────────────────────────────────────────────────────────────
class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.ad});
  final AdDetail ad;

  bool _boolMeta(String key) {
    try {
      final m = (ad as dynamic).meta;
      if (m is Map && m.containsKey(key)) {
        final v = m[key];
        if (v is bool) return v;
        if (v is num) return v != 0;
        if (v is String) {
          final s = v.trim().toLowerCase();
          return s == '1' || s == 'true';
        }
      }
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isVip = ad.isVipActive;
    final isPremium = ad.isPremiumActive;
    final hasCredit = _boolMeta('credit_available');
    final hasBarter = _boolMeta('barter_available');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (isVip)
          _Badge(
            text: 'VIP',
            bg: _DT.gold,
            fg: _DT.bg,
            icon: Icons.bolt_rounded,
          ),
        if (isPremium)
          _Badge(
            text: 'Premium',
            bg: _DT.accent,
            fg: Colors.white,
            icon: Icons.workspace_premium_rounded,
          ),
        if (hasBarter)
          _Badge(
            text: 'Barter',
            bg: _DT.card,
            fg: _DT.blue,
            icon: Icons.swap_horiz_rounded,
            border: true,
          ),
        if (hasCredit)
          _Badge(
            text: 'Kredit',
            bg: _DT.card,
            fg: _DT.green,
            icon: Icons.credit_card_rounded,
            border: true,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.bg,
    required this.fg,
    required this.icon,
    this.border = false,
  });

  final String text;
  final Color bg;
  final Color fg;
  final IconData icon;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: border ? Border.all(color: _DT.cardBorder) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            text,
            style: _DT.syne(s: 12, w: FontWeight.w700, c: fg),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROMO
// ─────────────────────────────────────────────────────────────────────────────
class _PromoRow extends StatelessWidget {
  const _PromoRow({required this.onTap});
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        children: [
          _PromoChip(
            label: 'İrəli çək',
            sub: '0.50 AZN',
            colors: [_DT.green, const Color(0xFF0EAA6A)],
            onTap: () => onTap('discover'),
          ),
          const SizedBox(width: 8),
          _PromoChip(
            label: 'VIP',
            sub: '2.55 AZN',
            colors: [_DT.gold, const Color(0xFFD49500)],
            onTap: () => onTap('vip'),
          ),
          const SizedBox(width: 8),
          _PromoChip(
            label: 'Premium',
            sub: '3.50 AZN',
            colors: [_DT.accent, const Color(0xFFE63900)],
            onTap: () => onTap('premium'),
          ),
        ],
      ),
    );
  }
}

class _PromoChip extends StatelessWidget {
  const _PromoChip({
    required this.label,
    required this.sub,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final String sub;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: _DT.syne(s: 13, w: FontWeight.w800, c: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: _DT.dm(s: 11, c: Colors.white.withOpacity(0.75)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPECS
// ─────────────────────────────────────────────────────────────────────────────
class _SpecsSection extends StatelessWidget {
  const _SpecsSection({required this.ad});
  final AdDetail ad;

  @override
  Widget build(BuildContext context) {
    final specs = <_SpecData>[];
    if (ad.city != null) specs.add(_SpecData('Şəhər', ad.city!.name));

    for (final a in ad.attributes) {
      if (a.label.trim().isNotEmpty && a.value.trim().isNotEmpty) {
        specs.add(_SpecData(a.label, a.value));
      }
    }

    if (specs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: Text(
            'Xüsusiyyətlər',
            style: _DT.syne(s: 16, w: FontWeight.w800),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: specs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _SpecCard(spec: specs[i]),
          ),
        ),
      ],
    );
  }
}

class _SpecData {
  const _SpecData(this.label, this.value);
  final String label;
  final String value;
}

class _SpecCard extends StatelessWidget {
  const _SpecCard({required this.spec});
  final _SpecData spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      constraints: const BoxConstraints(minWidth: 100),
      decoration: BoxDecoration(
        color: _DT.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DT.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spec.label, style: _DT.dm(s: 11, c: _DT.textLow)),
          const SizedBox(height: 5),
          Text(
            spec.value,
            style: _DT.syne(s: 14, w: FontWeight.w700, c: _DT.textHi),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIN
// ─────────────────────────────────────────────────────────────────────────────
class _VinSection extends StatelessWidget {
  const _VinSection({required this.vin, required this.onCopy});
  final String vin;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _DT.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'VIN',
                  style: _DT.syne(s: 12, w: FontWeight.w800, c: _DT.gold),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCopy,
                child: const Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: _DT.textMid,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            vin,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _DT.textHi,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Avtomobil almadan öncə VIN-u yoxlayın',
            style: _DT.dm(s: 12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESCRIPTION
// ─────────────────────────────────────────────────────────────────────────────
class _DescSection extends StatelessWidget {
  const _DescSection({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Təsvir', style: _DT.syne(s: 16, w: FontWeight.w800)),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            firstChild: Text(
              text,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: _DT.dm(s: 14, c: _DT.textMid),
            ),
            secondChild: Text(
              text,
              style: _DT.dm(s: 14, c: _DT.textMid),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onToggle,
            child: Text(
              expanded ? '↑ Daha az' : '↓ Ətraflı oxu',
              style: _DT.syne(s: 13, w: FontWeight.w700, c: _DT.gold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELLER CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SellerCard extends StatelessWidget {
  const _SellerCard({
    required this.ad,
    required this.sellerName,
    required this.avatarUrl,
    required this.isStore,
    required this.isOpen,
    required this.isVerified,
    required this.workHours,
    required this.phone,
    required this.onOpenSeller,
    required this.onCall,
    required this.onMessage,
  });

  final AdDetail ad;
  final String sellerName;
  final String? avatarUrl;
  final bool isStore;
  final bool? isOpen;
  final bool isVerified;
  final String? workHours;
  final String phone;
  final VoidCallback onOpenSeller;
  final VoidCallback? onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _DT.cardBorder),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1D27), Color(0xFF111318)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _SellerAvatar(url: avatarUrl, size: 54),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: onOpenSeller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                sellerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _DT.syne(s: 17, w: FontWeight.w800),
                              ),
                            ),
                            if (isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.verified_rounded,
                                  size: 18,
                                  color: _DT.gold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            _MicroTag(
                              text: isStore ? 'Mağaza' : 'Satıcı',
                              color: isStore ? _DT.blue : _DT.textMid,
                            ),
                            if (isOpen != null) ...[
                              const SizedBox(width: 8),
                              _MicroTag(
                                text: isOpen! ? 'Açıqdır' : 'Bağlıdır',
                                color: isOpen!
                                    ? _DT.green
                                    : const Color(0xFFFF5C5C),
                                dot: true,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onOpenSeller,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _DT.cardBorder),
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: _DT.textMid,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (workHours != null) ...[
            Divider(height: 1, color: _DT.cardBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: _DT.textLow,
                  ),
                  const SizedBox(width: 8),
                  Text('İş saatları: $workHours', style: _DT.dm(s: 13)),
                ],
              ),
            ),
          ],
          Divider(height: 1, color: _DT.cardBorder),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: _CTAButton(
                    text: phone.isEmpty ? 'Nömrə yoxdur' : 'Zəng et',
                    icon: Icons.call_rounded,
                    gradient: [_DT.blue, const Color(0xFF2855CC)],
                    onTap: onCall,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CTAButton(
                    text: 'Mesaj yaz',
                    icon: Icons.chat_bubble_rounded,
                    gradient: [_DT.green, const Color(0xFF0EAA6A)],
                    onTap: onMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  const _SellerAvatar({required this.url, required this.size});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 4,
      height: size + 4,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_DT.gold, _DT.accent, _DT.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: _DT.surface,
          backgroundImage:
              (url != null && url!.isNotEmpty) ? NetworkImage(url!) : null,
          child: (url == null || url!.isEmpty)
              ? Icon(Icons.person, color: _DT.textMid, size: size * 0.45)
              : null,
        ),
      ),
    );
  }
}

class _MicroTag extends StatelessWidget {
  const _MicroTag({
    required this.text,
    required this.color,
    this.dot = false,
  });

  final String text;
  final Color color;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
        ],
        Text(
          text,
          style: _DT.dm(s: 12, c: color, w: FontWeight.w600),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// META
// ─────────────────────────────────────────────────────────────────────────────
class _AdMetaSection extends StatelessWidget {
  const _AdMetaSection({required this.ad, required this.onComplaint});
  final AdDetail ad;
  final VoidCallback onComplaint;

  static String _shortDate(String? iso) {
    if (iso == null || iso.length < 10) return '';
    return '${iso.substring(8, 10)}.${iso.substring(5, 7)}.${iso.substring(0, 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return _DarkCard(
      child: Column(
        children: [
          _MetaRow(label: 'Elan №', value: '${ad.id}'),
          _MetaRow(label: 'Baxış', value: '${ad.viewsCount}'),
          if (ad.createdAt != null)
            _MetaRow(label: 'Tarix', value: _shortDate(ad.createdAt)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1500),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _DT.gold.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: _DT.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Beh göndərməmişdən öncə sövdələşmənin etibarlılığını yoxlayın.',
                    style: _DT.dm(s: 12, c: const Color(0xFFE8C44A)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onComplaint,
            child: Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  size: 16,
                  color: Color(0xFFFF5C5C),
                ),
                const SizedBox(width: 8),
                Text(
                  'Şikayət et',
                  style: _DT.dm(
                    s: 13,
                    c: const Color(0xFFFF5C5C),
                    w: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: _DT.dm(s: 13)),
          const Spacer(),
          Text(value, style: _DT.syne(s: 13, w: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIMILAR
// ─────────────────────────────────────────────────────────────────────────────
class _SimilarSection extends ConsumerWidget {
  const _SimilarSection({required this.adId});
  final int adId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adSimilarProvider(adId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            'Bənzər elanlar',
            style: _DT.syne(s: 18, w: FontWeight.w800),
          ),
        ),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Xəta: $e', style: _DT.dm()),
          ),
          data: (list) {
            final items = list
                .map((m) => SimilarAd.fromMap(m))
                .where((x) => x.id > 0)
                .toList();

            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Bənzər elan tapılmadı', style: _DT.dm()),
              );
            }

            return SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _SimilarTile(ad: items[i]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SimilarTile extends StatelessWidget {
  const _SimilarTile({required this.ad});
  final SimilarAd ad;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdDetailScreen(adId: ad.id)),
      ),
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: _DT.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _DT.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ad.coverUrl.isEmpty
                      ? Container(
                          color: _DT.surface,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: _DT.textLow,
                            ),
                          ),
                        )
                      : Image.network(
                          ad.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _DT.surface,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: _DT.textLow,
                              ),
                            ),
                          ),
                        ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ad.cityName,
                        style: _DT.syne(s: 10, c: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                '${ad.priceText} ${ad.currency}',
                style: _DT.syne(s: 15, w: FontWeight.w800, c: _DT.gold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                ad.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _DT.dm(s: 12, c: _DT.textMid),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING BAR
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingBar extends StatelessWidget {
  const _FloatingBar({
    required this.phone,
    required this.avatarUrl,
    required this.onCall,
    required this.onMessage,
    required this.onAvatar,
  });

  final String phone;
  final String? avatarUrl;
  final VoidCallback? onCall;
  final VoidCallback onMessage;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF111318).withOpacity(0.92),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _DT.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _CTAButton(
                      text: phone.isEmpty ? 'Nömrə yoxdur' : 'Zəng et',
                      icon: Icons.call_rounded,
                      gradient: [_DT.blue, const Color(0xFF2855CC)],
                      onTap: onCall,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onAvatar,
                    child: _SellerAvatar(url: avatarUrl, size: 40),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CTAButton(
                      text: 'Mesaj yaz',
                      icon: Icons.chat_bubble_rounded,
                      gradient: [_DT.green, const Color(0xFF0EAA6A)],
                      onTap: onMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHONE SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneSheet extends StatelessWidget {
  const _PhoneSheet({required this.phone, required this.onCopy});
  final String phone;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _DT.textLow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              phone,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _DT.textHi,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Kopyala'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _DT.textHi,
                      side: const BorderSide(color: _DT.cardBorder),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Zəng et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _DT.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYMENT
// ─────────────────────────────────────────────────────────────────────────────
class _PayCfg {
  final String title;
  final String infoSub;
  final IconData icon;
  final List<Color> colors;
  final List<_PayDur> durations;

  const _PayCfg({
    required this.title,
    required this.infoSub,
    required this.icon,
    required this.colors,
    required this.durations,
  });
}

class _PayDur {
  final int days;
  final double price;
  const _PayDur(this.days, this.price);
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.cfg});
  final _PayCfg cfg;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  int _selectedDays = 0;
  String _method = 'balance';

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.cfg.durations.first.days;
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.cfg;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _DT.textLow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: cfg.colors),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(cfg.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(cfg.title, style: _DT.syne(s: 22, w: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              Text(cfg.infoSub, style: _DT.dm()),
              const SizedBox(height: 20),
              Text('MÜDDƏT', style: _DT.syne(s: 11, c: _DT.textLow)),
              const SizedBox(height: 10),
              ...cfg.durations.map((d) {
                final sel = d.days == _selectedDays;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDays = d.days),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: sel ? cfg.colors.first.withOpacity(0.12) : _DT.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel
                            ? cfg.colors.first.withOpacity(0.5)
                            : _DT.cardBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${d.days} gün',
                            style: _DT.syne(
                              s: 14,
                              w: FontWeight.w700,
                              c: sel ? _DT.textHi : _DT.textMid,
                            ),
                          ),
                        ),
                        Text(
                          '${d.price.toStringAsFixed(2)} AZN',
                          style: _DT.syne(
                            s: 14,
                            w: FontWeight.w800,
                            c: sel ? cfg.colors.first : _DT.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              Text('ÖDƏMƏ ÜSULU', style: _DT.syne(s: 11, c: _DT.textLow)),
              const SizedBox(height: 10),
              ...[
                ('balance', 'Şəxsi hesab'),
                ('saved_card', 'Visa •• 2029'),
                ('bank_card', 'Bank kartı'),
              ].map((m) {
                final sel = _method == m.$1;
                return GestureDetector(
                  onTap: () => setState(() => _method = m.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: sel ? _DT.card : const Color(0xFF0D0F15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel
                            ? _DT.gold.withOpacity(0.4)
                            : _DT.cardBorder,
                      ),
                    ),
                    child: Text(
                      m.$2,
                      style: _DT.dm(
                        c: sel ? _DT.textHi : _DT.textMid,
                        w: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              _CTAButton(
                text: 'Ödə',
                icon: Icons.arrow_forward_rounded,
                gradient: cfg.colors,
                onTap: () {
                  Navigator.pop(context);
                },
                height: 56,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIGHTBOX
// ─────────────────────────────────────────────────────────────────────────────
class _LightboxDialog extends StatefulWidget {
  const _LightboxDialog({
    required this.gallery,
    required this.initialIndex,
  });

  final List<String> gallery;
  final int initialIndex;

  @override
  State<_LightboxDialog> createState() => _LightboxDialogState();
}

class _LightboxDialogState extends State<_LightboxDialog> {
  late final PageController _pageCtrl;
  late int _idx;
  late final List<TransformationController> _transformCtrls;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _idx = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
    _transformCtrls = List.generate(
      widget.gallery.length,
      (_) => TransformationController(),
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _transformCtrls) {
      c.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _updateZoomState() {
    final scale = _transformCtrls[_idx].value.getMaxScaleOnAxis();
    final zoomed = scale > 1.01;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  void _resetZoomFor(int pageIndex) {
    _transformCtrls[pageIndex].value = Matrix4.identity();
  }

  void _resetCurrentZoom() {
    _resetZoomFor(_idx);
    if (_isZoomed) {
      setState(() => _isZoomed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gallery.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Icon(Icons.image_not_supported_outlined, color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageCtrl,
              physics: _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: widget.gallery.length,
              onPageChanged: (i) {
                _resetZoomFor(_idx);
                setState(() {
                  _idx = i;
                  _isZoomed = false;
                });
              },
              itemBuilder: (_, i) {
                final url = widget.gallery[i];

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: InteractiveViewer(
                    transformationController: _transformCtrls[i],
                    minScale: 1,
                    maxScale: 5,
                    panEnabled: i == _idx ? _isZoomed : false,
                    scaleEnabled: true,
                    boundaryMargin: const EdgeInsets.all(24),
                    clipBehavior: Clip.none,
                    onInteractionUpdate: (_) {
                      if (i == _idx) _updateZoomState();
                    },
                    onInteractionEnd: (_) {
                      if (i == _idx) _updateZoomState();
                    },
                    child: Center(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              color: _DT.gold,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: _DT.textLow,
                            size: 52,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Text(
                        '${_idx + 1} / ${widget.gallery.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _isZoomed ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: GestureDetector(
                          onTap: _isZoomed ? _resetCurrentZoom : null,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: const Icon(
                              Icons.zoom_out_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (widget.gallery.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      math.min(widget.gallery.length, 12),
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _idx ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _idx
                              ? _DT.gold
                              : Colors.white.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (widget.gallery.length > 1 && !_isZoomed) ...[
            if (_idx > 0)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pageCtrl.previousPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    ),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            if (_idx < widget.gallery.length - 1)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    ),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED
// ─────────────────────────────────────────────────────────────────────────────
class _DarkCard extends StatelessWidget {
  const _DarkCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DT.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _DT.cardBorder),
      ),
      child: child,
    );
  }
}

class _CTAButton extends StatelessWidget {
  const _CTAButton({
    required this.text,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.height = 50,
    this.fullWidth = false,
  });

  final String text;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final double height;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          width: fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: _DT.syne(s: 14, w: FontWeight.w700, c: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GBtn extends StatelessWidget {
  const _GBtn({
    required this.icon,
    required this.onTap,
    this.accent,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Icon(icon, color: accent ?? Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING / ERROR
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DT.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _DT.gold, strokeWidth: 2),
            const SizedBox(height: 16),
            Text('Yüklənir...', style: _DT.dm()),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DT.bg,
      appBar: AppBar(
        backgroundColor: _DT.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _DT.textHi),
      ),
      body: Center(
        child: Text(
          'Xəta: $error',
          style: _DT.dm(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}