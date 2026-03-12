import 'dart:ui';
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

class AdDetailScreen extends ConsumerStatefulWidget {
  const AdDetailScreen({super.key, required this.adId});
  final int adId;

  @override
  ConsumerState<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends ConsumerState<AdDetailScreen> {
  final PageController _page = PageController(viewportFraction: 1);

  int _imgIndex = 0;
  bool _descExpanded = false;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adDetailProvider(widget.adId));
    final isFav = ref.watch(isFavoriteProvider(widget.adId));

    return async.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text('Elan'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Xəta: $e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (AdDetail ad) {
        final gallery = ad.galleryUrls;
        final phone = _resolveSellerPhone(ad);
        final storeOpenNow = _resolveStoreOpen(ad);
        final sellerAvatarUrl = _resolveSellerAvatar(ad);
        final isStore = ad.store != null;
        final sellerName = ad.store?.name ?? ad.user?.name ?? 'İstifadəçi';

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          extendBody: true,
          bottomNavigationBar: _FloatingContactBar(
            phone: phone,
            avatarUrl: sellerAvatarUrl,
            onCall: phone.isEmpty ? null : () => _showPhoneSheet(context, phone),
            onAvatarTap: () => _openSeller(ad),
            onMessage: () => _handleMessageTap(ad),
          ),
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroGallery(
                    pageController: _page,
                    gallery: gallery,
                    currentIndex: _imgIndex,
                    isFav: isFav,
                    onPageChanged: (i) => setState(() => _imgIndex = i),
                    onBack: () => Navigator.of(context).maybePop(),
                    onShare: () => _shareAd(ad),
                    onFav: () async {
                      await ref
                          .read(favoritesControllerProvider.notifier)
                          .toggle(widget.adId);
                    },
                    onOpenFullGallery: () => _openGalleryLightbox(gallery),
                    title: ad.title,
                    priceText: '${_priceText(ad)} ${ad.currency}',
                    cityText: ad.city?.name ?? '',
                    metaText: 'Elan №${ad.id}',
                    sellerName: sellerName,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -26),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _GlassSection(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TopBadgesRow(
                                  hasCredit: _boolMeta(ad, 'credit_available'),
                                  hasBarter: _boolMeta(ad, 'barter_available'),
                                  isStore: isStore,
                                  storeOpenNow: storeOpenNow,
                                  isVerified: _isSellerVerified(ad),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '${_priceText(ad)} ${ad.currency}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    height: 1.05,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  ad.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _PromoTile(
                                        title: 'Kəşf et',
                                        sub: '3 AZN-dən',
                                        icon: Icons.auto_awesome,
                                        colors: const [
                                          Color(0xFF34D399),
                                          Color(0xFF10B981),
                                        ],
                                        onTap: () => _openPaymentSheet(
                                          context,
                                          service: 'discover',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _PromoTile(
                                        title: 'VIP',
                                        sub: '5 AZN-dən',
                                        icon: Icons.bolt_rounded,
                                        colors: const [
                                          Color(0xFFFFB347),
                                          Color(0xFFFF7A00),
                                        ],
                                        onTap: () => _openPaymentSheet(
                                          context,
                                          service: 'vip',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _PromoTile(
                                        title: 'Premium',
                                        sub: '7 AZN-dən',
                                        icon: Icons.workspace_premium_rounded,
                                        colors: const [
                                          Color(0xFFFF5C8A),
                                          Color(0xFFFF3366),
                                        ],
                                        onTap: () => _openPaymentSheet(
                                          context,
                                          service: 'premium',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_stringMeta(ad, 'vin').isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _SoftCard(
                              child: _VinCard(
                                vin: _stringMeta(ad, 'vin'),
                                onCopy: () async {
                                  final vin = _stringMeta(ad, 'vin');
                                  if (vin.isEmpty) return;
                                  await Clipboard.setData(ClipboardData(text: vin));
                                  if (!mounted) return;
                                  _toast(context, 'VIN kopyalandı');
                                },
                                onSearch: () {
                                  final vin = _stringMeta(ad, 'vin');
                                  if (vin.isEmpty) return;
                                  _toast(context, 'VIN axtarışı üçün browser qoşulacaq');
                                },
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _SoftCard(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                const _SectionTitle('Xüsusiyyətlər'),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    if (ad.city != null)
                                      _SpecPill(
                                        label: 'Şəhər',
                                        value: ad.city!.name,
                                      ),
                                    for (final a in ad.attributes)
                                      if (a.label.trim().isNotEmpty &&
                                          a.value.trim().isNotEmpty)
                                        _SpecPill(
                                          label: a.label,
                                          value: a.value,
                                        ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        if ((ad.description ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _SoftCard(
                              child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                  const _SectionTitle('Təsvir'),
                                  const SizedBox(height: 12),
                                  AnimatedCrossFade(
                                    firstChild: Text(
                                      ad.description!,
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.55,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    secondChild: Text(
                                      ad.description!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.65,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    crossFadeState: _descExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 220),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _descExpanded = !_descExpanded),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        _descExpanded ? 'Daha az' : 'Ətraflı oxu',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _SellerSpotlightCard(
                            avatarUrl: sellerAvatarUrl,
                            title: sellerName,
                            subtitle: isStore ? 'Mağaza profili' : 'İstifadəçi profili',
                            isStore: isStore,
                            isOpen: storeOpenNow,
                            isVerified: _isSellerVerified(ad),
                            workHours: _resolveWorkHours(ad),
                            phone: phone,
                            onOpenSeller: () => _openSeller(ad),
                            onFollow: () => _toast(
                              context,
                              'İzləmə API qoşulanda aktiv ediləcək',
                            ),
                            onCall: phone.isEmpty ? null : () => _showPhoneSheet(context, phone),
                            onMessage: () => _handleMessageTap(ad),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _WarningPanel(),
                        ),

                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _SoftCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle('Elan məlumatı'),
                                const SizedBox(height: 14),
                                _MetaLine(label: 'Elanın nömrəsi', value: '${ad.id}'),
                                _MetaLine(
                                  label: 'Baxışların sayı',
                                  value: '${ad.viewsCount}',
                                ),
                                _MetaLine(
                                  label: 'Paylaşılıb',
                                  value: _shortDate(ad.createdAt),
                                ),
                                const SizedBox(height: 14),
                                GestureDetector(
                                  onTap: () => _openComplaint(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF1F2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.flag_outlined,
                                          color: Color(0xFFBE123C),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Şikayət et',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF881337),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _SimilarAdsSection(adId: ad.id),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMessageTap(AdDetail ad) async {
    final authState = ref.read(authControllerProvider);
    final isLoggedIn = authState.user != null;

    if (!isLoggedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );

      if (!mounted) return;
    }

    final authStateAfter = ref.read(authControllerProvider);
    final loggedInNow = authStateAfter.user != null;

    if (!loggedInNow) {
      _toast(context, 'Mesaj yazmaq üçün daxil olun');
      return;
    }

    final partnerId = ad.user?.id;
    if (partnerId == null) {
      _toast(context, 'Mesaj göndəriləcək istifadəçi tapılmadı');
      return;
    }

    if (authStateAfter.user?.id == partnerId) {
      _toast(context, 'Bu sizin öz elanınızdır');
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageThreadScreen(
          partnerId: partnerId,
          adId: ad.id,
        ),
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

    _toast(context, 'Profil tapılmadı');
  }

  Future<void> _shareAd(AdDetail ad) async {
    final text = '${ad.title} - ${_priceText(ad)} ${ad.currency}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _toast(context, 'Elan məlumatı kopyalandı');
  }

  void _openGalleryLightbox(List<String> gallery) {
    if (gallery.isEmpty) return;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(.92),
      builder: (_) => _GalleryLightbox(
        gallery: gallery,
        initialIndex: _imgIndex,
      ),
    );
  }

  String _resolveSellerPhone(AdDetail ad) {
    final storePhone = ad.store?.phone?.trim();
    if (storePhone != null && storePhone.isNotEmpty) return storePhone;

    final userPhone = ad.user?.phone?.trim();
    if (userPhone != null && userPhone.isNotEmpty) return userPhone;

    return '';
  }

  bool? _resolveStoreOpen(AdDetail ad) {
    try {
      final dynamic store = ad.store;
      if (store == null) return null;
      final dynamic v = store.isOpenNow;
      if (v is bool) return v;
    } catch (_) {}
    return null;
  }

  String? _resolveSellerAvatar(AdDetail ad) {
    try {
      final dynamic store = ad.store;
      if (store != null) {
        final dynamic logoUrl = store.logoUrl;
        if (logoUrl is String && logoUrl.trim().isNotEmpty) {
          return logoUrl.trim();
        }
      }
    } catch (_) {}

    try {
      final dynamic user = ad.user;
      if (user != null) {
        final dynamic photoUrl = user.photoUrl;
        if (photoUrl is String && photoUrl.trim().isNotEmpty) {
          return photoUrl.trim();
        }
      }
    } catch (_) {}

    return null;
  }

  bool _isSellerVerified(AdDetail ad) {
    try {
      final dynamic store = ad.store;
      if (store != null) {
        final dynamic v = store.isVerified;
        if (v is bool) return v;
      }
    } catch (_) {}

    try {
      final dynamic user = ad.user;
      if (user != null) {
        final dynamic v = user.isVerified;
        if (v is bool) return v;
      }
    } catch (_) {}

    return false;
  }

  String? _resolveWorkHours(AdDetail ad) {
    try {
      final dynamic store = ad.store;
      if (store == null) return null;
      final from = store.workFrom?.toString();
      final to = store.workTo?.toString();
      if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
        return '$from - $to';
      }
    } catch (_) {}
    return null;
  }

  bool _boolMeta(AdDetail ad, String key) {
    try {
      final dynamic raw = ad;
      final dynamic meta = raw.meta;
      if (meta is Map && meta.containsKey(key)) {
        final v = meta[key];
        if (v is bool) return v;
        if (v is num) return v != 0;
        if (v is String) {
          final s = v.trim().toLowerCase();
          return s == '1' || s == 'true' || s == 'yes';
        }
      }
    } catch (_) {}
    return false;
  }

  String _stringMeta(AdDetail ad, String key) {
    try {
      final dynamic raw = ad;
      final dynamic meta = raw.meta;
      if (meta is Map && meta.containsKey(key) && meta[key] != null) {
        return meta[key].toString().trim();
      }
    } catch (_) {}
    return '';
  }

  void _openComplaint(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) {
        final reasons = const [
          'Artıq satılıb',
          'Dələduz',
          'Kontaktlar yanlış göstərilib',
          'Qiymət yanlış göstərilib',
          'Saxta elan',
          'Şəkillər yanlışdır',
          'Digər',
        ];

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Text(
                  'Şikayətin səbəbi',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              for (final r in reasons)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    r,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    _openComplaintText(context, r);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openComplaintText(BuildContext context, String reason) {
    final c = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reason,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Burada şikayətinizi daha ətraflı təsvir edə bilərsiniz.',
                  filled: true,
                  fillColor: const Color(0xFFF4F6F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Eyni elana gün ərzində maksimum 3 şikayət göndərə bilərsiniz.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _toast(context, 'Şikayət API qoşulanda aktiv ediləcək');
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF111827),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Göndər'),
                ),
              ),
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
      backgroundColor: const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) {
        String selectedMethod = 'balance';
        int selectedDays = cfg.durations.first.days;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          cfg.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: cfg.colors.first.withOpacity(.12),
                            ),
                            child: Icon(cfg.icon, color: cfg.colors.last),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cfg.infoTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cfg.infoSub,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'MÜDDƏT SEÇİN',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...cfg.durations.map((d) {
                      final selected = d.days == selectedDays;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedDays = d.days),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.05),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: d.days,
                                  groupValue: selectedDays,
                                  onChanged: (_) =>
                                      setModalState(() => selectedDays = d.days),
                                ),
                                Expanded(
                                  child: Text(
                                    '${d.days} gün',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${d.price.toStringAsFixed(2)} AZN',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ÖDƏMƏ ÜSULU',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...[
                      ('balance', 'Şəxsi hesab'),
                      ('saved_card', 'Visa .. 2029'),
                      ('terminal', 'Terminallarda ödəniş'),
                      ('bank_card', 'Bank kartı'),
                    ].map((m) {
                      final selected = selectedMethod == m.$1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setModalState(() => selectedMethod = m.$1),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: m.$1,
                                  groupValue: selectedMethod,
                                  onChanged: (_) =>
                                      setModalState(() => selectedMethod = m.$1),
                                ),
                                Expanded(
                                  child: Text(
                                    m.$2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _toast(
                            context,
                            '${cfg.title}: $selectedDays gün / $selectedMethod / backend qoşulanda aktiv olacaq',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: cfg.colors.last,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Ödə'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPhoneSheet(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nömrə',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                phone,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: phone));
                        if (!mounted) return;
                        _toast(context, 'Nömrə kopyalandı');
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Kopyala'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _toast(context, 'Zəng üçün url_launcher qoşulacaq');
                      },
                      icon: const Icon(Icons.call_rounded),
                      label: const Text('Zəng et'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _PaymentSheetConfig _paymentConfig(String service) {
    switch (service) {
      case 'discover':
        return const _PaymentSheetConfig(
          title: 'İrəli çək',
          infoTitle: 'Axtarışda yuxarı çıxın',
          infoSub: 'Elan axtarış nəticələrində daha yuxarıda göstəriləcək.',
          icon: Icons.auto_awesome,
          colors: [Color(0xFF34D399), Color(0xFF10B981)],
          durations: [
            _PaymentDuration(days: 1, price: 0.50),
            _PaymentDuration(days: 3, price: 1.20),
            _PaymentDuration(days: 7, price: 2.20),
          ],
        );
      case 'premium':
        return const _PaymentSheetConfig(
          title: 'Premium et',
          infoTitle: 'Daha çox görünüş qazanın',
          infoSub: 'Premium elanlar daha çox baxış toplayır.',
          icon: Icons.workspace_premium_rounded,
          colors: [Color(0xFFFF5C8A), Color(0xFFFF3366)],
          durations: [
            _PaymentDuration(days: 5, price: 3.50),
            _PaymentDuration(days: 15, price: 8.90),
            _PaymentDuration(days: 30, price: 14.90),
          ],
        );
      default:
        return const _PaymentSheetConfig(
          title: 'VIP et',
          infoTitle: 'Daha çox alıcıya çatın',
          infoSub:
              'Elan daha ön planda görünəcək və daha çox diqqət çəkəcək.',
          icon: Icons.bolt_rounded,
          colors: [Color(0xFFFFB347), Color(0xFFFF7A00)],
          durations: [
            _PaymentDuration(days: 5, price: 2.55),
            _PaymentDuration(days: 15, price: 6.38),
            _PaymentDuration(days: 30, price: 10.63),
          ],
        );
    }
  }

  static String _priceText(AdDetail ad) {
    final ps = (ad.priceStr ?? '').trim();
    if (ps.isNotEmpty) return ps;

    final p = ad.price;
    if (p == null) return '';
    if (p % 1 == 0) return p.toStringAsFixed(0);
    return p.toStringAsFixed(2);
  }

  static String _shortDate(String? iso) {
    if (iso == null || iso.length < 10) return '';
    final y = iso.substring(0, 4);
    final m = iso.substring(5, 7);
    final d = iso.substring(8, 10);
    return '$d.$m.$y';
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({
    required this.pageController,
    required this.gallery,
    required this.currentIndex,
    required this.isFav,
    required this.onPageChanged,
    required this.onBack,
    required this.onShare,
    required this.onFav,
    required this.onOpenFullGallery,
    required this.title,
    required this.priceText,
    required this.cityText,
    required this.metaText,
    required this.sellerName,
  });

  final PageController pageController;
  final List<String> gallery;
  final int currentIndex;
  final bool isFav;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onFav;
  final VoidCallback onOpenFullGallery;
  final String title;
  final String priceText;
  final String cityText;
  final String metaText;
  final String sellerName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 490,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: onOpenFullGallery,
            child: PageView.builder(
              controller: pageController,
              itemCount: gallery.isEmpty ? 1 : gallery.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) {
                final url = gallery.isEmpty ? '' : gallery[i];
                if (url.isEmpty) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 62,
                        color: Colors.black26,
                      ),
                    ),
                  );
                }
                return Image.network(url, fit: BoxFit.cover);
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.20),
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.58),
                  ],
                  stops: const [0.0, 0.45, 1.0],
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
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: onBack,
                    ),
                    const Spacer(),
                    _GlassIconButton(
                      icon: Icons.ios_share_rounded,
                      onTap: onShare,
                    ),
                    const SizedBox(width: 10),
                    _GlassIconButton(
                      icon: isFav ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFav ? Colors.redAccent : Colors.white,
                      onTap: onFav,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (gallery.length > 1)
            Positioned(
              right: 16,
              top: 110,
              child: _GlassIconButton(
                icon: Icons.zoom_out_map_rounded,
                onTap: onOpenFullGallery,
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniGlassTag(
                  text: gallery.isEmpty ? '0/0' : '${currentIndex + 1}/${gallery.length}',
                ),
                const SizedBox(height: 14),
                Text(
                  priceText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 31,
                    letterSpacing: -0.8,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (cityText.trim().isNotEmpty) _MiniGlassTag(text: cityText),
                    _MiniGlassTag(text: metaText),
                    _MiniGlassTag(text: sellerName),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryLightbox extends StatefulWidget {
  const _GalleryLightbox({
    required this.gallery,
    required this.initialIndex,
  });

  final List<String> gallery;
  final int initialIndex;

  @override
  State<_GalleryLightbox> createState() => _GalleryLightboxState();
}

class _GalleryLightboxState extends State<_GalleryLightbox> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.gallery.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      widget.gallery[i],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 36,
            left: 20,
            child: _LightboxIcon(
              icon: Icons.close_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 38,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_index + 1}/${widget.gallery.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LightboxIcon extends StatelessWidget {
  const _LightboxIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(.45),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.white.withOpacity(0.18),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniGlassTag extends StatelessWidget {
  const _MiniGlassTag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white.withOpacity(0.14),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FAFC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TopBadgesRow extends StatelessWidget {
  const _TopBadgesRow({
    required this.hasCredit,
    required this.hasBarter,
    required this.isStore,
    required this.storeOpenNow,
    required this.isVerified,
  });

  final bool hasCredit;
  final bool hasBarter;
  final bool isStore;
  final bool? storeOpenNow;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (hasBarter)
        const _SoftTag(
          text: 'Barter',
          bg: Color(0xFFEEF2FF),
          fg: Color(0xFF4338CA),
          icon: Icons.swap_horiz_rounded,
        ),
      if (hasCredit)
        const _SoftTag(
          text: 'Kredit',
          bg: Color(0xFFECFDF3),
          fg: Color(0xFF047857),
          icon: Icons.credit_card_rounded,
        ),
      _SoftTag(
        text: isStore ? 'Mağaza' : 'İstifadəçi',
        bg: const Color(0xFFF3F4F6),
        fg: const Color(0xFF111827),
        icon: isStore ? Icons.storefront_rounded : Icons.person_rounded,
      ),
      if (isVerified)
        const _SoftTag(
          text: 'Təsdiqli',
          bg: Color(0xFFFFF7ED),
          fg: Color(0xFFD97706),
          icon: Icons.verified_rounded,
        ),
      if (storeOpenNow != null)
        _SoftTag(
          text: storeOpenNow! ? 'Açıqdır' : 'Bağlıdır',
          bg: storeOpenNow! ? const Color(0xFFECFDF3) : const Color(0xFFFEF2F2),
          fg: storeOpenNow! ? const Color(0xFF047857) : const Color(0xFFB91C1C),
          icon: Icons.schedule_rounded,
        ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}

class _SoftTag extends StatelessWidget {
  const _SoftTag({
    required this.text,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  final String text;
  final Color bg;
  final Color fg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({
    required this.title,
    required this.sub,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String sub;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 18,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _VinCard extends StatelessWidget {
  const _VinCard({
    required this.vin,
    required this.onCopy,
    required this.onSearch,
  });

  final String vin;
  final VoidCallback onCopy;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('VIN'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        vin,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: .4,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('İnternetdə axtar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Avtomobil almadan öncə VIN-kodu yoxlayın.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SpecPill extends StatelessWidget {
  const _SpecPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerSpotlightCard extends StatelessWidget {
  const _SellerSpotlightCard({
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.isStore,
    required this.isOpen,
    required this.isVerified,
    required this.workHours,
    required this.phone,
    required this.onOpenSeller,
    required this.onFollow,
    required this.onCall,
    required this.onMessage,
  });

  final String? avatarUrl;
  final String title;
  final String subtitle;
  final bool isStore;
  final bool? isOpen;
  final bool isVerified;
  final String? workHours;
  final String phone;

  final VoidCallback onOpenSeller;
  final VoidCallback onFollow;
  final VoidCallback? onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF111827),
            Color(0xFF1F2937),
            Color(0xFF0F172A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                _AvatarGlow(
                  avatarUrl: avatarUrl,
                  size: 58,
                ),
                const SizedBox(width: 12),
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
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            if (isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFFFBBF24),
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DarkTag(
                              text: isStore ? 'Mağaza' : 'İstifadəçi',
                              icon: isStore
                                  ? Icons.storefront_rounded
                                  : Icons.person_rounded,
                            ),
                            if (isOpen != null)
                              _DarkTag(
                                text: isOpen! ? 'Açıqdır' : 'Bağlıdır',
                                icon: Icons.schedule_rounded,
                                activeColor:
                                    isOpen! ? const Color(0xFF22C55E) : const Color(0xFFF87171),
                              )
                            else
                              _DarkTag(
                                text: subtitle,
                                icon: Icons.verified_user_outlined,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (workHours != null && workHours!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'İş saatları: $workHours',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionCapsule(
                    text: isStore ? 'Mağazaya bax' : 'Profilə bax',
                    icon: Icons.arrow_outward_rounded,
                    dark: false,
                    onTap: onOpenSeller,
                  ),
                ),
                if (isStore) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionCapsule(
                      text: '+ izlə',
                      icon: Icons.add_rounded,
                      dark: true,
                      onTap: onFollow,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _LargeCTAButton(
                    text: phone.isEmpty ? 'Nömrə yoxdur' : 'Zəng et',
                    icon: Icons.call_rounded,
                    colors: const [
                      Color(0xFF2563EB),
                      Color(0xFF1D4ED8),
                    ],
                    onTap: onCall,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LargeCTAButton(
                    text: 'Mesaj yaz',
                    icon: Icons.chat_bubble_rounded,
                    colors: const [
                      Color(0xFF22C55E),
                      Color(0xFF16A34A),
                    ],
                    onTap: onMessage,
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

class _AvatarGlow extends StatelessWidget {
  const _AvatarGlow({
    required this.avatarUrl,
    required this.size,
  });

  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF60A5FA),
            Color(0xFF34D399),
            Color(0xFFF472B6),
          ],
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: const Color(0xFF111827),
          backgroundImage: (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
              ? NetworkImage(avatarUrl!.trim())
              : null,
          child: (avatarUrl == null || avatarUrl!.trim().isEmpty)
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _DarkTag extends StatelessWidget {
  const _DarkTag({
    required this.text,
    required this.icon,
    this.activeColor = const Color(0xFF9CA3AF),
  });

  final String text;
  final IconData icon;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: activeColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCapsule extends StatelessWidget {
  const _ActionCapsule({
    required this.text,
    required this.icon,
    required this.dark,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? Colors.white.withOpacity(0.12) : Colors.white;
    final fg = dark ? Colors.white : const Color(0xFF111827);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeCTAButton extends StatelessWidget {
  const _LargeCTAButton({
    required this.text,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: colors),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 19),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WarningPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF7ED),
            Color(0xFFFFFBEB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF59E0B).withOpacity(0.12),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_moon_rounded,
            color: Color(0xFFD97706),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diqqət!',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Beh göndərməmişdən öncə sövdələşmənin təhlükəsiz olduğuna əmin olun!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: Color(0xFFB45309),
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

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingContactBar extends StatelessWidget {
  const _FloatingContactBar({
    required this.phone,
    required this.onCall,
    required this.onMessage,
    required this.avatarUrl,
    required this.onAvatarTap,
  });

  final String phone;
  final VoidCallback? onCall;
  final VoidCallback onMessage;
  final String? avatarUrl;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _BottomActionButton(
                      text: 'Zəng et',
                      icon: Icons.call_rounded,
                      colors: const [
                        Color(0xFF2563EB),
                        Color(0xFF1D4ED8),
                      ],
                      onTap: onCall,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: _AvatarGlow(
                      avatarUrl: avatarUrl,
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BottomActionButton(
                      text: 'Mesaj yaz',
                      icon: Icons.chat_bubble_rounded,
                      colors: const [
                        Color(0xFF22C55E),
                        Color(0xFF16A34A),
                      ],
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

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.text,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 19),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SimilarAdsSection extends ConsumerWidget {
  const _SimilarAdsSection({required this.adId});
  final int adId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adSimilarProvider(adId));

    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Bənzər elanlar'),
          const SizedBox(height: 14),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Xəta: $e'),
            data: (list) {
              final items = list
                  .map((m) => SimilarAd.fromMap(m))
                  .where((x) => x.id > 0)
                  .toList();

              if (items.isEmpty) {
                return const Text(
                  'Bənzər elan tapılmadı',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                );
              }

              return SizedBox(
                height: 265,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _SimilarAdTile(ad: items[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SimilarAdTile extends StatelessWidget {
  const _SimilarAdTile({required this.ad});
  final SimilarAd ad;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdDetailScreen(adId: ad.id)),
        );
      },
      child: Container(
        width: 182,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
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
                          color: const Color(0xFFE5E7EB),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.black26,
                              size: 36,
                            ),
                          ),
                        )
                      : Image.network(ad.coverUrl, fit: BoxFit.cover),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        ad.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Text(
                '${ad.priceText} ${ad.currency}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                ad.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.3,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSheetConfig {
  final String title;
  final String infoTitle;
  final String infoSub;
  final IconData icon;
  final List<Color> colors;
  final List<_PaymentDuration> durations;

  const _PaymentSheetConfig({
    required this.title,
    required this.infoTitle,
    required this.infoSub,
    required this.icon,
    required this.colors,
    required this.durations,
  });
}

class _PaymentDuration {
  final int days;
  final double price;

  const _PaymentDuration({
    required this.days,
    required this.price,
  });
}