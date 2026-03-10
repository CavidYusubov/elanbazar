import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads_detail/ui/ad_detail_screen.dart';
import '../../discover/ui/ad_card.dart';
import '../state/favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(favoritesControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff3f3f5),
      appBar: AppBar(
        title: const Text('Seçilmişlər'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(favoritesControllerProvider.notifier).refresh(),
        child: Builder(
          builder: (_) {
            if (st.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (st.items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Seçilmiş elan yoxdur',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ],
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              itemCount: st.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                mainAxisExtent: 248,
              ),
              itemBuilder: (context, i) {
                final ad = st.items[i];
                final isFav = ref.watch(isFavoriteProvider(ad.id));

                return AdCard(
                  adId: ad.id,
                  title: ad.title,
                  price: ad.priceStr.isNotEmpty
                      ? ad.priceStr
                      : ad.price.toStringAsFixed(ad.price % 1 == 0 ? 0 : 2),
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
              },
            );
          },
        ),
      ),
    );
  }
}