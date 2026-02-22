import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/publisher.dart';
import '../state/ad_detail_controller.dart';
import 'package:elanbazar/features/profile/user_profile_screen.dart';
import 'package:elanbazar/features/profile/store_profile_screen.dart';

class AdDetailScreen extends ConsumerWidget {
  final int adId;
  const AdDetailScreen({super.key, required this.adId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAd = ref.watch(adDetailProvider(adId));

    return asyncAd.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Detail error: $e')),
      ),
      data: (ad) {
        final title = (ad['title'] ?? '').toString();
        final priceStr = (ad['price_str'] ?? ad['price'] ?? '').toString();
        final currency = (ad['currency'] ?? 'AZN').toString();

        final city = (ad['city'] is Map) ? (ad['city']['name'] ?? '') : '';
        final desc = (ad['description'] ?? '').toString();

        final images = (ad['images'] is List) ? (ad['images'] as List) : const [];
        final coverUrl = (ad['cover_url'] ?? '').toString();

        Publisher? publisher;
        if (ad['publisher'] is Map) {
          publisher = Publisher.fromJson(Map<String, dynamic>.from(ad['publisher']));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.favorite, color: Colors.red)),
                ],
                expandedHeight: 320,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: images.isNotEmpty ? images.length : 1,
                        itemBuilder: (context, i) {
                          final url = images.isNotEmpty
                              ? (images[i]['url'] ?? images[i]['full_url'] ?? images[i]['path'] ?? coverUrl).toString()
                              : coverUrl;

                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              images.isNotEmpty ? '1 / ${images.length}' : '1 / 1',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$priceStr $currency',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 14),

                      // VIP buttons row (sənin dizayna yaxın)
                      Row(
                        children: [
                          _pill('Kəşf et\n3 AZN-dən', Colors.green),
                          const SizedBox(width: 10),
                          _pill('VIP\n5 AZN-dən', Colors.orange),
                          const SizedBox(width: 10),
                          _pill('Premium\n7 AZN-dən', Colors.red),
                        ],
                      ),

                      const SizedBox(height: 18),
                      const Text('Şəhər', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(city.toString(), style: const TextStyle(fontWeight: FontWeight.w900)),

                      const SizedBox(height: 18),
                      Text(desc, style: const TextStyle(height: 1.35)),

                      const SizedBox(height: 18),
                      const Divider(),

                      // publisher block (user or store)
                      if (publisher != null)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (publisher!.type == 'user') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => UserProfileScreen(userId: publisher!.id)),
                                    );
                                  } else if (publisher!.type == 'store') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => StoreProfileScreen(
                                                slug: publisher!.slug ?? publisher!.id.toString(),
                                              )),
                                    );
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundImage: (publisher?.avatarUrl != null && publisher!.avatarUrl!.isNotEmpty)
                                      ? NetworkImage(publisher!.avatarUrl!)
                                      : null,
                                  child: (publisher?.avatarUrl == null || publisher!.avatarUrl!.isEmpty)
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(publisher!.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 4),
                                    Text(
                                        publisher!.type == 'user'
                                            ? 'İstifadəçi profili'
                                            : 'Mağaza profili',
                                        style: const TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Zəng et'),
                              )
                            ],
                          ),
                        ),
                      if (publisher == null)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(radius: 26, child: Icon(Icons.person)),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('İstifadəçi', style: TextStyle(fontWeight: FontWeight.w900)),
                                    SizedBox(height: 4),
                                    Text('Profil detayı sonra bağlanacaq', style: TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Zəng et'),
                              )
                            ],
                          ),
                        ),

                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text('BƏNZƏR ELANLAR', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black54)),
                      ),
                      const SizedBox(height: 12),

                      // Similar ads: hələlik placeholder
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (_, __) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(14),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _pill(String t, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: c, width: 1.3),
          borderRadius: BorderRadius.circular(14),
          color: c.withOpacity(0.06),
        ),
        child: Text(t, style: TextStyle(color: c, fontWeight: FontWeight.w900)),
      ),
    );
  }
}