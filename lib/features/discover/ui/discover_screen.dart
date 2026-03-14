import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads_detail/ui/ad_detail_screen.dart';
import '../../reels/ui/reels_screen.dart';
import '../data/discover_repo.dart';
import '../data/models/ad_list_item.dart';
import '../data/models/discover_category_item.dart';
import '../state/discover_controller.dart';
import 'ad_card.dart';
import 'package:elanbazar/features/shell/ui/main_shell.dart';
import '../../favorites/state/favorites_controller.dart';
class DiscoverScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenReels;

  const DiscoverScreen({
    super.key,
    this.onOpenReels,
  });

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _minCtrl = TextEditingController();
  final TextEditingController _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = ref.read(discoverControllerProvider);
      _searchCtrl.text = st.query;
      _minCtrl.text = st.minPrice?.toString() ?? '';
      _maxCtrl.text = st.maxPrice?.toString() ?? '';
    });
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;

    if (pos.maxScrollExtent - pos.pixels < 600) {
      ref.read(discoverControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(discoverControllerProvider);

    if (_searchCtrl.text != st.query) {
      _searchCtrl.text = st.query;
      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchCtrl.text.length),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff3f3f5),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(discoverControllerProvider.notifier).refresh(),
          child: Builder(
            builder: (_) {
              final nothingLoaded = st.premiumItems.isEmpty &&
                  st.vipItems.isEmpty &&
                  st.latestItems.isEmpty &&
                  st.listingItems.isEmpty &&
                  st.categoryRailItems.isEmpty &&
                  st.categoryRailRoot == null &&
                  st.selectedCategory == null;

              if (st.loading && nothingLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              if (st.error != null && nothingLoaded) {
                return ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(
                      child: Text(
                        'Xəta: ${st.error}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                );
              }

              return CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(child: _buildTopHeader(context)),
                  SliverToBoxAdapter(child: _buildSearchBar(context, st)),
                  SliverToBoxAdapter(child: _buildFilterPills(context, st)),
                  if (st.hasActiveFilters)
                    SliverToBoxAdapter(child: _buildActiveFilterChips(context, st)),
                  SliverToBoxAdapter(child: _buildCategoryRail(st)),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (!st.isListingMode) ...[
                    SliverToBoxAdapter(
                      child: _buildPreviewSection(
                        context,
                        title: 'Premium Elanlar',
                        items: st.premiumItems,
                        onSeeAll: () {
                          ref.read(discoverControllerProvider.notifier).openScope(
                                'premium',
                                title: 'Premium Elanlar',
                              );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildPreviewSection(
                        context,
                        title: 'VIP Elanlar',
                        items: st.vipItems,
                        onSeeAll: () {
                          ref.read(discoverControllerProvider.notifier).openScope(
                                'vip',
                                title: 'VIP Elanlar',
                              );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildPreviewSection(
                        context,
                        title: 'Son elanlar',
                        items: st.latestItems,
                        onSeeAll: () {
                          ref.read(discoverControllerProvider.notifier).openScope(
                                'latest',
                                title: 'Son elanlar',
                              );
                        },
                      ),
                    ),
                  ] else ...[
                    SliverToBoxAdapter(
                      child: _buildListingHeader(
                        title: st.listingTitle,
                        onBack: () {
                          ref.read(discoverControllerProvider.notifier).backToHome();
                        },
                      ),
                    ),
                    if (st.loading && st.listingItems.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 36),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else if (st.listingItems.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(14, 10, 14, 20),
                          child: Text(
                            'Heç nə tapılmadı',
                            style: TextStyle(fontSize: 16, color: Colors.black45),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            mainAxisExtent: 248,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final ad = st.listingItems[i];
                              return _buildAdCard(context, ad);
                            },
                            childCount: st.listingItems.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: st.loadingMore
                              ? const CircularProgressIndicator()
                              : (!st.hasMore && st.listingItems.isNotEmpty
                                  ? const Text(
                                      'Son',
                                      style: TextStyle(color: Colors.black54),
                                    )
                                  : const SizedBox.shrink()),
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.onOpenReels != null) {
                      widget.onOpenReels!();
                      return;
                    }

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MainShell(
                          initialIndex: 0,
                          initialHomeTab: HomeTopTab.reels,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Sənin üçün',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Text(
                  '  |  ',
                  style: TextStyle(color: Colors.white38, fontSize: 18),
                ),
                const Text(
                  'Bütün elanlar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, DiscoverState st) {
    return Container(
      color: const Color(0xfff3f3f5),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xffe7e7ea)),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) {
                  ref.read(discoverControllerProvider.notifier).setQuery(v);
                },
                onSubmitted: (_) {
                  ref.read(discoverControllerProvider.notifier).applyFilters();
                },
                decoration: const InputDecoration(
                  hintText: 'Nə axtarırsan?',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 17),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _squareButton(
            icon: Icons.search,
            bg: const Color(0xff18c652),
            iconColor: Colors.white,
            onTap: () {
              ref.read(discoverControllerProvider.notifier).applyFilters();
            },
          ),
          const SizedBox(width: 10),
          _squareButton(
            icon: Icons.tune,
            bg: Colors.white,
            iconColor: Colors.black87,
            onTap: () => _showAllFiltersSheet(context, st),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills(BuildContext context, DiscoverState st) {
    final cityLabel = st.selectedCity?.name ?? 'Bütün şəhərlər';
    final sortLabel = _sortLabel(st.sort);

    return Container(
      color: const Color(0xfff3f3f5),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _pillButton(
              icon: Icons.tune,
              text: 'Bütün filtrlər',
              primary: true,
              onTap: () => _showAllFiltersSheet(context, st),
            ),
            const SizedBox(width: 8),
            _pillButton(
              icon: Icons.location_on_outlined,
              text: cityLabel,
              onTap: () => _showCitySheet(context, st),
            ),
            const SizedBox(width: 8),
            _pillButton(
              icon: Icons.swap_vert,
              text: sortLabel,
              onTap: () => _showSortSheet(context, st),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips(BuildContext context, DiscoverState st) {
    return Container(
      color: const Color(0xfff3f3f5),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (st.query.trim().isNotEmpty)
            _chip(
              label: 'Axtarış: "${st.query}"',
              onRemove: () {
                ref.read(discoverControllerProvider.notifier).removeQuery();
              },
            ),
          if (st.selectedCategory != null)
            _chip(
              label: 'Kateqoriya: ${st.selectedCategory!.name}',
              onRemove: () {
                ref.read(discoverControllerProvider.notifier).backToHome();
              },
            ),
          if (st.selectedCity != null)
            _chip(
              label: 'Şəhər: ${st.selectedCity!.name}',
              onRemove: () {
                ref.read(discoverControllerProvider.notifier).removeCity();
              },
            ),
          if (st.minPrice != null)
            _chip(
              label: 'Min: ${st.minPrice} AZN',
              onRemove: () {
                ref.read(discoverControllerProvider.notifier).removeMinPrice();
              },
            ),
          if (st.maxPrice != null)
            _chip(
              label: 'Maks: ${st.maxPrice} AZN',
              onRemove: () {
                ref.read(discoverControllerProvider.notifier).removeMaxPrice();
              },
            ),
          if (st.sort != 'date_desc')
            _chip(
              label: 'Sıralama: ${_sortLabel(st.sort)}',
              onRemove: () {
                ref.read(discoverControllerProvider.notifier).resetSort();
              },
            ),
          GestureDetector(
            onTap: () {
              ref.read(discoverControllerProvider.notifier).clearFilters();
              _searchCtrl.clear();
              _minCtrl.clear();
              _maxCtrl.clear();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xfff5f6f8),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xffe5e7eb)),
              ),
              child: const Text(
                'Bütün filtrləri sil',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xfff5f6f8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRail(DiscoverState st) {
    final widgets = <Widget>[];

    widgets.add(
      _buildCategoryCard(
        title: 'All',
        imageUrl: null,
        active: st.selectedCategory == null,
        icon: Icons.grid_view_rounded,
        onTap: () {
          ref.read(discoverControllerProvider.notifier).backToHome();
        },
      ),
    );

    if (st.categoryRailRoot != null) {
      final root = st.categoryRailRoot!;
      widgets.add(
        _buildCategoryCard(
          title: root.name,
          imageUrl: root.imageUrl,
          active: st.selectedCategory?.id == root.id,
          icon: Icons.folder_outlined,
          onTap: () {
            ref.read(discoverControllerProvider.notifier).openCategory(root);
          },
        ),
      );
    }

    for (final c in st.categoryRailItems) {
      widgets.add(
        _buildCategoryCard(
          title: c.name,
          imageUrl: c.imageUrl,
          active: st.selectedCategory?.id == c.id,
          icon: Icons.folder_outlined,
          onTap: () {
            ref.read(discoverControllerProvider.notifier).openCategory(c);
          },
        ),
      );
    }

    return Container(
      color: const Color(0xfff3f3f5),
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: widgets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => widgets[i],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String? imageUrl,
    required bool active,
    required VoidCallback onTap,
    IconData icon = Icons.folder_outlined,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 118,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xffeff6ff) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xff0ea5e9) : const Color(0xffe5e7eb),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xfff3f4f6),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        icon,
                        color: const Color(0xff4b5563),
                        size: 20,
                      ),
                    )
                  : Icon(
                      icon,
                      color: const Color(0xff4b5563),
                      size: 20,
                    ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff111827),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(
    BuildContext context, {
    required String title,
    required List<AdListItem> items,
    required VoidCallback onSeeAll,
  }) {
    return Container(
      width: double.infinity,
      color: const Color(0xfff3f3f5),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'Hamısına bax',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff18c652),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text(
                'Heç nə tapılmadı',
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
            )
          else
            GridView.builder(
              itemCount: items.length > 4 ? 4 : items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                mainAxisExtent: 248,
              ),
              itemBuilder: (context, i) {
                return _buildAdCard(context, items[i]);
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildListingHeader({
    required String title,
    required VoidCallback onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffe7e7ea)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, AdListItem ad) {
  final isFav = ref.watch(isFavoriteProvider(ad.id));

  return AdCard(
    adId: ad.id,
    title: ad.title,
    price: ad.priceStr.isNotEmpty ? ad.priceStr : ad.price.toStringAsFixed(0),
    currency: ad.currency,
    coverUrl: ad.coverUrl,
    user: ad.publisher?.name ?? ad.userName,
    city: ad.cityName,
    date: ad.dateStr,
    publisher: ad.publisher,
    isVip: ad.isVipActive,
    isPremium: ad.isPremiumActive,
    isFavorite: isFav,
    onFavoriteTap: () async {
      await ref.read(favoritesControllerProvider.notifier).toggle(ad.id);
    },
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AdDetailScreen(adId: ad.id),
        ),
      );
    },
  );
}

  Widget _squareButton({
    required IconData icon,
    required Color bg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: bg == Colors.white ? const Color(0xffe7e7ea) : bg,
          ),
        ),
        child: Icon(icon, color: iconColor, size: 26),
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: primary ? const Color(0xffecfdf5) : Colors.white,
          border: Border.all(
            color: primary ? const Color(0xff10b981) : const Color(0xffe5e7eb),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: primary ? const Color(0xff047857) : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: primary ? const Color(0xff047857) : Colors.black87,
                fontWeight: primary ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCitySheet(BuildContext context, DiscoverState st) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Şəhər seçin',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 12),
              _sheetOption(
                label: 'Bütün şəhərlər',
                active: st.cityId == null,
                onTap: () async {
                  Navigator.pop(context);
                  ref.read(discoverControllerProvider.notifier).setCity(null);
                  await ref.read(discoverControllerProvider.notifier).applyFilters();
                },
              ),
              ...st.cities.map((c) {
                return _sheetOption(
                  label: c.name,
                  active: st.cityId == c.id,
                  onTap: () async {
                    Navigator.pop(context);
                    ref.read(discoverControllerProvider.notifier).setCity(c.id);
                    await ref.read(discoverControllerProvider.notifier).applyFilters();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSortSheet(BuildContext context, DiscoverState st) async {
    final options = [
      ('date_desc', 'Ən yenilər'),
      ('price_asc', 'Qiymət artan'),
      ('price_desc', 'Qiymət azalan'),
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Sıralama',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 12),
              ...options.map((o) {
                return _sheetOption(
                  label: o.$2,
                  active: st.sort == o.$1,
                  onTap: () async {
                    Navigator.pop(context);
                    ref.read(discoverControllerProvider.notifier).setSort(o.$1);
                    await ref.read(discoverControllerProvider.notifier).applyFilters();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAllFiltersSheet(BuildContext context, DiscoverState st) async {
    _searchCtrl.text = st.query;
    _minCtrl.text = st.minPrice?.toString() ?? '';
    _maxCtrl.text = st.maxPrice?.toString() ?? '';

    int? cityId = st.cityId;
    String sort = st.sort;
    String categoryLabel = st.selectedCategory?.name ?? 'Cari seçim';
    final queryCtrl = TextEditingController(text: st.query);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Axtarışı dəqiqləşdirin',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      const SizedBox(height: 14),
                      _fieldLabel('Açar söz'),
                      _textField(queryCtrl, 'Məs: iPhone 13, Sony TV ...'),
                      const SizedBox(height: 12),
                      _fieldLabel('Məkan'),
                      _dropdownBox(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            isExpanded: true,
                            value: cityId,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Bütün şəhərlər'),
                              ),
                              ...st.cities.map(
                                (c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              setModal(() {
                                cityId = v;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _fieldLabel('Kateqoriya'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xffe5e7eb)),
                        ),
                        child: Text(categoryLabel),
                      ),
                      const SizedBox(height: 12),
                      _fieldLabel('Min qiymət (AZN)'),
                      _textField(_minCtrl, ''),
                      const SizedBox(height: 12),
                      _fieldLabel('Maks qiymət (AZN)'),
                      _textField(_maxCtrl, ''),
                      const SizedBox(height: 12),
                      _fieldLabel('Sıralama'),
                      _dropdownBox(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: sort,
                            items: const [
                              DropdownMenuItem(
                                value: 'date_desc',
                                child: Text('Ən yenilər'),
                              ),
                              DropdownMenuItem(
                                value: 'price_asc',
                                child: Text('Qiymət artan'),
                              ),
                              DropdownMenuItem(
                                value: 'price_desc',
                                child: Text('Qiymət azalan'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setModal(() {
                                sort = v;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                _searchCtrl.clear();
                                _minCtrl.clear();
                                _maxCtrl.clear();
                                await ref.read(discoverControllerProvider.notifier).clearFilters();
                              },
                              child: const Text('Sıfırla'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);

                                ref.read(discoverControllerProvider.notifier).setQuery(queryCtrl.text.trim());

                                ref.read(discoverControllerProvider.notifier).setCity(cityId);

                                ref.read(discoverControllerProvider.notifier).setPriceRange(
                                  minPrice: double.tryParse(_minCtrl.text.trim()),
                                  maxPrice: double.tryParse(_maxCtrl.text.trim()),
                                );

                                ref.read(discoverControllerProvider.notifier).setSort(sort);

                                await ref.read(discoverControllerProvider.notifier).applyFilters();
                              },
                              child: const Text('Axtar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetOption({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: active ? const Color(0xffecfdf5) : Colors.white,
            border: Border.all(
              color: active ? const Color(0xff10b981) : const Color(0xffe5e7eb),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: active ? const Color(0xff047857) : Colors.black87,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffe5e7eb)),
        ),
      ),
    );
  }

  Widget _dropdownBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: child,
    );
  }

  String _sortLabel(String sort) {
    switch (sort) {
      case 'price_asc':
        return 'Qiymət artan';
      case 'price_desc':
        return 'Qiymət azalan';
      default:
        return 'Ən yenilər';
    }
  }
}