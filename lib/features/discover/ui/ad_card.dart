import 'package:flutter/material.dart';
import '../../../core/models/publisher.dart';
import 'package:elanbazar/features/profile/user_profile_screen.dart';
import 'package:elanbazar/features/profile/store_profile_screen.dart';

class AdCard extends StatelessWidget {
  final String title;
  final String price;
  final String currency;
  final String coverUrl;
  final String user;
  final String city;
  final String date;
  final Publisher? publisher;
  final bool isVip;
  final bool isPremium;
  final VoidCallback onTap;

  const AdCard({
    super.key,
    required this.title,
    required this.price,
    required this.currency,
    required this.coverUrl,
    required this.user,
    required this.city,
    required this.date,
    required this.publisher,
    required this.isVip,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        clipBehavior: Clip.antiAlias, // ✅ kənardan daşmanı da kəsir
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ şəkil - Expanded ilə yuxarı hissə
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, size: 18),
                    ),
                  ),
                  if (isVip || isPremium)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isPremium ? 'PREMIUM' : 'VIP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ✅ qiymət
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Text(
                '$price $currency',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),

            // ✅ title (maxLines 2 etsən daha stabil olar)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),

            // ✅ ALT hissə (Spacer YOX!)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final p = publisher;
                      if (p == null) return;

                      if (p.type == 'user') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => UserProfileScreen(userId: p.id)),
                        );
                      } else if (p.type == 'store') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StoreProfileScreen(slug: p.slug ?? p.id.toString()),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: (publisher?.avatarUrl != null &&
                              publisher!.avatarUrl!.isNotEmpty)
                          ? NetworkImage(publisher!.avatarUrl!)
                          : null,
                      child: (publisher?.avatarUrl == null || publisher!.avatarUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 14)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        Text(
                          city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _shortDate(date),
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.55),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(String iso) {
    if (iso.length >= 10) {
      final m = iso.substring(5, 7);
      final d = iso.substring(8, 10);
      return '$d.$m';
    }
    return '';
  }
}