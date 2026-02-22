import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/ad_detail_provider.dart';
import '../models/ad_detail.dart';
import '../state/ad_similar_provider.dart';
import '../models/similar_ad.dart';
import '../../profile/user_profile_screen.dart';
import '../../profile/store_profile_screen.dart';
class AdDetailScreen extends ConsumerStatefulWidget {
  const AdDetailScreen({super.key, required this.adId});
  final int adId;

  @override
  ConsumerState<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends ConsumerState<AdDetailScreen> {
  final _page = PageController();
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

    return async.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Elan')),
        body: Center(child: Text('Xəta: $e')),
      ),
      data: (AdDetail ad) {
        final gallery = ad.galleryUrls;

        // seller phone priority: store > user
        final phone = (ad.store?.phone?.trim().isNotEmpty == true)
            ? ad.store!.phone!.trim()
            : (ad.user?.phone?.trim() ?? '');

        final storeOpenNow = ad.store?.isOpenNow;

        return Scaffold(
          backgroundColor: Colors.white,

          // ✅ Detail-in öz contact barı
         bottomNavigationBar: _ContactBar(
  phone: phone,
  onCall: phone.isEmpty ? null : () => _showPhoneSheet(context, phone),
  onMessage: () => _toast(context, 'Mesaj: sonra qoşacağıq'),
  avatarUrl: null,
  onAvatarTap: () {
  if (ad.store != null && (ad.store!.slug ?? '').trim().isNotEmpty) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StoreProfileScreen(slug: ad.store!.slug!.trim())),
    );
    return;
  }
  if (ad.user != null) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserProfileScreen(userId: ad.user!.id)),
    );
    return;
  }
  _toast(context, 'Profil tapılmadı');
},
),

          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                // =========================
                // GALLERY + TOPBAR
                // =========================
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.2,
                        child: PageView.builder(
                          controller: _page,
                          itemCount: gallery.length,
                          onPageChanged: (i) => setState(() => _imgIndex = i),
                          itemBuilder: (_, i) {
                            final url = gallery[i];
                            if (url.isEmpty) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.image, size: 48, color: Colors.black26),
                                ),
                              );
                            }
                            return Image.network(url, fit: BoxFit.cover);
                          },
                        ),
                      ),

                      // counter
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_imgIndex + 1}/${gallery.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // topbar
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Row(
                              children: [
                                _TopIcon(
                                  icon: Icons.arrow_back_ios_new,
                                  onTap: () => Navigator.of(context).maybePop(),
                                ),
                                const Spacer(),
                                _TopIcon(
                                  icon: Icons.share,
                                  onTap: () => _toast(context, 'Share: sonra'),
                                ),
                                const SizedBox(width: 10),
                                _TopIcon(
                                  icon: Icons.favorite_border,
                                  onTap: () => _toast(context, 'Seçilmiş: sonra'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================
                // PRICE + TITLE + PACKAGES
                // =========================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_priceText(ad)} ${ad.currency}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ad.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _ServiceChip(
                                title: 'Kəşf et',
                                sub: '3 AZN-dən',
                                color: Colors.green,
                                onTap: () => _toast(context, 'Kəşf et payment: sonra'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ServiceChip(
                                title: 'VIP',
                                sub: '5 AZN-dən',
                                color: Colors.orange,
                                onTap: () => _toast(context, 'VIP payment: sonra'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ServiceChip(
                                title: 'Premium',
                                sub: '7 AZN-dən',
                                color: Colors.red,
                                onTap: () => _toast(context, 'Premium payment: sonra'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // =========================
                // SPECS (Şəhər + attributes)
                // =========================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _Card(
                      child: Column(
                        children: [
                          if (ad.city != null) _SpecRow(label: 'Şəhər', value: ad.city!.name),
                          for (final a in ad.attributes)
                            if (a.label.trim().isNotEmpty && a.value.trim().isNotEmpty)
                              _SpecRow(label: a.label, value: a.value),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================
                // DESCRIPTION (toggle)
                // =========================
                if ((ad.description ?? '').trim().isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.description!,
                              maxLines: _descExpanded ? null : 4,
                              overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.85),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () => setState(() => _descExpanded = !_descExpanded),
                              child: Text(
                                _descExpanded ? 'Daha az' : 'Ətraflı oxu',
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // =========================
                // SELLER CARD (store/user)
                // =========================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _SellerCard(
                      isStore: ad.store != null,
                      storeName: ad.store?.name,
                      storeSlug: ad.store?.slug,
                      storeOpenNow: storeOpenNow,
                      userName: ad.user?.name,
                      phone: phone,
                      onOpenSeller: () {
                      if (ad.store != null && (ad.store!.slug ?? '').trim().isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StoreProfileScreen(slug: ad.store!.slug!.trim()),
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
                    },
                      onFollow: () => _toast(context, 'İzləmə: sonra'),
                      onCall: phone.isEmpty ? null : () => _showPhoneSheet(context, phone),
                      onMessage: () => _toast(context, 'Mesaj: sonra'),
                    ),
                  ),
                ),

                // =========================
                // WARNING BOX
                // =========================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Diqqət!', style: TextStyle(fontWeight: FontWeight.w900)),
                                SizedBox(height: 4),
                                Text(
                                  'Beh göndərməmişdən öncə sövdələşmənin təhlükəsiz olduğuna əmin olun!',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================
                // META + COMPLAINT
                // =========================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: _Card(
                      child: Column(
                        children: [
                          _MetaRow(label: 'Elanın nömrəsi:', value: '${ad.id}'),
                          _MetaRow(label: 'Baxışların sayı:', value: '${ad.viewsCount}'),
                          _MetaRow(label: 'Paylaşılıb:', value: _shortDate(ad.createdAt)),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => _openComplaint(context),
                            child: Row(
                              children: const [
                                Icon(Icons.flag_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Şikayət et', style: TextStyle(fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================
// SIMILAR ADS
// =========================
// =========================
// SIMILAR ADS
// =========================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _SimilarAdsSection(adId: ad.id),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openComplaint(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
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
        return ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Şikayətin səbəbi', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            for (final r in reasons)
              ListTile(
                title: Text(r, style: const TextStyle(fontWeight: FontWeight.w800)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _openComplaintText(context, r);
                },
              ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
void _openSeller(BuildContext context, AdDetail ad) {
  if (ad.store != null && (ad.store!.slug ?? '').trim().isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreProfileScreen(slug: ad.store!.slug!.trim()),
      ),
    );
    return;
  }

  if (ad.user != null && ad.user!.id != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: ad.user!.id!),
      ),
    );
    return;
  }

  _toast(context, 'Profil tapılmadı');
}
  void _openComplaintText(BuildContext context, String reason) {
    final c = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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
              Text(reason, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              TextField(
                controller: c,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Burada şikayətinizı daha ətraflı təsvir edə bilərsiniz.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Eyni elana gün ərzində maksimum 3 şikayət göndərə bilərsiniz.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _toast(context, 'Şikayət: API gələndə göndərəcəyik');
                  },
                  child: const Text('Göndər'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhoneSheet(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nömrə', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              SelectableText(phone, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _toast(context, 'Zəng: url_launcher ilə qoşacağıq');
                  },
                  icon: const Icon(Icons.call),
                  label: const Text('Zəng et'),
                ),
              ),
            ],
          ),
        );
      },
    );
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _TopIcon extends StatelessWidget {
  const _TopIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.title,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bolt, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.black.withOpacity(0.65), fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
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
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.black.withOpacity(0.65), fontWeight: FontWeight.w700),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({
    required this.isStore,
    required this.storeName,
    required this.storeSlug,
    required this.storeOpenNow,
    required this.userName,
    required this.phone,
    required this.onOpenSeller,
    required this.onFollow,
    required this.onCall,
    required this.onMessage,
  });

  final bool isStore;
  final String? storeName;
  final String? storeSlug;
  final bool? storeOpenNow;
  final String? userName;
  final String phone;

  final VoidCallback onOpenSeller;
  final VoidCallback onFollow;
  final VoidCallback? onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final title = isStore ? (storeName ?? 'Mağaza') : (userName ?? 'İstifadəçi');
    final badge = isStore ? 'Mağaza' : 'İstifadəçi';

    final openTxt = storeOpenNow == null ? '' : (storeOpenNow! ? 'Açıqdır' : 'Bağlıdır');

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 22, backgroundColor: Colors.black12, child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onOpenSeller,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(badge, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                          if (openTxt.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              openTxt,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: (storeOpenNow ?? false) ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpenSeller,
                  child: Text(isStore ? 'Mağazaya bax' : 'İstifadəçinin elanları'),
                ),
              ),
              if (isStore) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFollow,
                    child: const Text('+ izlə'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call),
              label: Text(phone.isEmpty ? 'Nömrə yoxdur' : 'Zəng et'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onMessage,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Mesaj yaz'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}


class _ContactBar extends StatelessWidget {
  const _ContactBar({
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.10))),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call),
                  label: const Text('Zəng et'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onAvatarTap,
              borderRadius: BorderRadius.circular(999),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.black12,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: onMessage,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Mesaj yaz'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
          ],
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

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bənzər elanlar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 12),

          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Xəta: $e', style: const TextStyle(fontWeight: FontWeight.w700)),
            data: (list) {
              final items = list
                  .map((m) => SimilarAd.fromMap(m))
                  .where((x) => x.id > 0)
                  .toList();

              if (items.isEmpty) {
                return Text(
                  'Bənzər elan tapılmadı',
                  style: TextStyle(color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w700),
                );
              }

              return SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdDetailScreen(adId: ad.id)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          color: Colors.white,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: ad.coverUrl.isEmpty
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image, size: 36, color: Colors.black26)),
                    )
                  : Image.network(ad.coverUrl, fit: BoxFit.cover),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Text(
                '${ad.priceText} ${ad.currency}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
              child: Text(
                ad.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Text(
                ad.cityName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}