import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/account_models.dart';
import '../state/account_controller.dart';
import 'following_screen.dart';
import 'followers_screen.dart';
import 'limits_screen.dart';
import 'profile_edit_screen.dart';
import 'transactions_screen.dart';
import 'wallet_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountControllerProvider);
    final controller = ref.read(accountControllerProvider.notifier);

    if (state.loading && state.account == null) {
      return const Scaffold(
        backgroundColor: Color(0xfff3f4f6),
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state.account == null) {
      return Scaffold(
        backgroundColor: const Color(0xfff3f4f6),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.refreshAll,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 80),
                Icon(
                  Icons.error_outline,
                  size: 52,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Məlumat yüklənmədi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    state.error ?? 'Naməlum xəta baş verdi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: ElevatedButton(
                    onPressed: controller.refreshAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff97316),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Yenidən yoxla',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final account = state.account!;
    final user = account.user;
    final isStore = user.store != null;

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshAll,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                children: [
                  if ((state.error ?? '').trim().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfffef2f2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xfffecaca)),
                      ),
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                          color: Color(0xffb91c1c),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  _HeaderCard(
                    user: user,
                    isStore: isStore,
                    followingCount: account.followingCount,
                    followersCount: account.followersCount,
                    onAvatarTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>  ProfileEditScreen(),
                        ),
                      );
                    },
                    onFollowingTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>  FollowingScreen(),
                        ),
                      );
                    },
                    onFollowersTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FollowersScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  _WalletCard(
                    balance: account.balance,
                    items: account.walletMenu,
                    onMenuTap: (item) {
                      switch (item.key) {
                        case 'wallet':
                        case 'balance':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WalletScreen(),
                            ),
                          );
                          break;

                        case 'transactions':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TransactionsScreen(),
                            ),
                          );
                          break;

                        case 'limits':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LimitsScreen(),
                            ),
                          );
                          break;

                        case 'cards':
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kartlarım səhifəsi sonra qoşulacaq'),
                            ),
                          );
                          break;

                        case 'promote':
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reklam et səhifəsi sonra qoşulacaq'),
                            ),
                          );
                          break;

                        case 'packages':
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Paketlər səhifəsi sonra qoşulacaq'),
                            ),
                          );
                          break;

                        case 'invoices':
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('İnvoyslar səhifəsi sonra qoşulacaq'),
                            ),
                          );
                          break;

                        default:
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.title} bölməsi hələ aktiv deyil'),
                            ),
                          );
                      }
                    },
                  ),
                  const SizedBox(height: 6),
                  _StatusTabs(
                    current: state.tab,
                    counts: account.counts,
                    onChanged: controller.changeTab,
                  ),
                  if (state.tab == 'archive') ...[
                    const SizedBox(height: 6),
                    const _ArchiveInfoCard(),
                  ],
                  const SizedBox(height: 6),
                  _AdsPanel(
                    items: state.ads,
                    loading: state.loading,
                    currentTab: state.tab,
                    onCreateTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Yeni elan hissəsi hələ qoşulmayıb'),
                        ),
                      );
                    },
                    onAdTap: (ad) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Elan #${ad.id} klikləndi'),
                        ),
                      );
                    },
                    onArchiveTap: (ad) async {
                      await controller.archiveAd(ad.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Elan arxivə göndərildi'),
                          ),
                        );
                      }
                    },
                    onRestoreTap: (ad) async {
                      await controller.restoreAd(ad.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Elan bərpa üçün göndərildi'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (state.saving)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: const Color(0x22000000),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final AccountUser user;
  final bool isStore;
  final int followingCount;
  final int followersCount;
  final VoidCallback onAvatarTap;
  final VoidCallback onFollowingTap;
  final VoidCallback onFollowersTap;

  const _HeaderCard({
    required this.user,
    required this.isStore,
    required this.followingCount,
    required this.followersCount,
    required this.onAvatarTap,
    required this.onFollowingTap,
    required this.onFollowersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe5e7eb)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0a0f172a),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onAvatarTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _Avatar(
                      imageUrl: user.photoUrl,
                      radius: 32,
                      iconSize: 32,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xffcbd5e1)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x330f172a),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 12,
                          color: Color(0xff4b5563),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          user.name.isEmpty ? 'İstifadəçi' : user.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff111827),
                          ),
                        ),
                        if (isStore)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff111827),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Mağaza',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if ((user.phone ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        user.phone!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff4b5563),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InkWell(
                          onTap: onFollowingTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: _InlineStatText(
                              value: followingCount,
                              label: 'izlədiklərim',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: onFollowersTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: _InlineStatText(
                              value: followersCount,
                              label: 'izləyənlər',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xffe5e7eb),
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Profil nömrəsi:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xffef4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${user.id}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff6b7280),
                      ),
                    ),
                  ],
                ),
                if ((user.createdAtHuman ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Color(0xff6b7280),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${user.createdAtHuman} tarixindən avtoal.az-da',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff6b7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineStatText extends StatelessWidget {
  final int value;
  final String label;

  const _InlineStatText({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xff111827),
              fontSize: 13,
            ),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xff111827),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final double balance;
  final List<AccountMenuItem> items;
  final ValueChanged<AccountMenuItem> onMenuTap;

  const _WalletCard({
    required this.balance,
    required this.items,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe5e7eb)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f0f172a),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Şəxsi hesab',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xff111827),
                  ),
                ),
              ),
              Text(
                '${balance.toStringAsFixed(2)} AZN',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xff111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: const Color(0xffe5e7eb),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onMenuTap(item),
                  child: SizedBox(
                    width: 92,
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xfff3f4f6),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xffe5e7eb)),
                          ),
                          child: Icon(
                            _menuIcon(item.icon),
                            size: 20,
                            color: const Color(0xff111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _menuIcon(String key) {
    switch (key) {
      case 'campaign':
        return Icons.campaign_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'fact_check':
        return Icons.fact_check_outlined;
      case 'business_center':
        return Icons.business_center_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}

class _StatusTabs extends StatelessWidget {
  final String current;
  final AccountCounts counts;
  final ValueChanged<String> onChanged;

  const _StatusTabs({
    required this.current,
    required this.counts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_StatusTabItem>[
      _StatusTabItem('live', 'Hazırda saytda', counts.live),
      _StatusTabItem('expired', 'Müddəti başa çatmış', counts.expired),
      _StatusTabItem('pending', 'Gözləmədə', counts.pending),
      _StatusTabItem('rejected', 'Dərc olunmamış', counts.rejected),
      _StatusTabItem('archive', 'Arxiv', counts.archive),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final active = item.key == current;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(item.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? const Color(0xfff97316) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? const Color(0xfff97316)
                      : const Color(0xffe5e7eb),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: active ? Colors.white : const Color(0xff374151),
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${item.count})',
                    style: TextStyle(
                      fontSize: 13,
                      color: active ? const Color(0xffffedd5) : const Color(0xff6b7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusTabItem {
  final String key;
  final String title;
  final int count;

  _StatusTabItem(this.key, this.title, this.count);
}

class _ArchiveInfoCard extends StatelessWidget {
  const _ArchiveInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xfff3f4f6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffe5e7eb)),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 18,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Bu bölmədə Arxivə göndərdiyiniz elanlar var. Onları istədiyiniz vaxt bərpa edə bilərsiniz.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xff374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdsPanel extends StatelessWidget {
  final List<AccountAdItem> items;
  final bool loading;
  final String currentTab;
  final VoidCallback onCreateTap;
  final ValueChanged<AccountAdItem> onAdTap;
  final ValueChanged<AccountAdItem> onArchiveTap;
  final ValueChanged<AccountAdItem> onRestoreTap;

  const _AdsPanel({
    required this.items,
    required this.loading,
    required this.currentTab,
    required this.onCreateTap,
    required this.onAdTap,
    required this.onArchiveTap,
    required this.onRestoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : items.isEmpty
              ? SizedBox(
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bu bölmədə elan yoxdur',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff6b7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: onCreateTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff16a34a),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '+ Yeni elan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  itemBuilder: (context, index) {
                    final ad = items[index];
                    return _AccountAdCard(
                      ad: ad,
                      currentTab: currentTab,
                      onTap: () => onAdTap(ad),
                      onArchiveTap: () => onArchiveTap(ad),
                      onRestoreTap: () => onRestoreTap(ad),
                    );
                  },
                ),
    );
  }
}

class _AccountAdCard extends StatelessWidget {
  final AccountAdItem ad;
  final String currentTab;
  final VoidCallback onTap;
  final VoidCallback onArchiveTap;
  final VoidCallback onRestoreTap;

  const _AccountAdCard({
    required this.ad,
    required this.currentTab,
    required this.onTap,
    required this.onArchiveTap,
    required this.onRestoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final showExpiredActions = currentTab == 'expired';
    final showArchiveActions = currentTab == 'archive';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffe5e7eb)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.15,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _NetworkImageBox(
                      imageUrl: ad.coverUrl,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  if (ad.isVip || ad.isPremium)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          ad.isPremium ? 'PREMIUM' : 'VIP',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Text(
                '${ad.priceFormatted} ${ad.currency}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xff111827),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              child: Text(
                ad.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xff111827),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 11,
                    backgroundColor: Color(0xffdbeafe),
                    child: Icon(
                      Icons.person,
                      size: 13,
                      color: Color(0xff2563eb),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ad.city ?? 'Bakı',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff111827),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    ad.publishedAtShort ?? '',
                    style: TextStyle(
                      color: Colors.black.withOpacity(.55),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (showExpiredActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onRestoreTap,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xffe0f2fe),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffbfdbfe)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Bərpa et',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff1d4ed8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: onArchiveTap,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xfff3f4f6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xffe5e7eb)),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Arxivlə',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff111827),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (showArchiveActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: InkWell(
                  onTap: onRestoreTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xffe0f2fe),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xffbfdbfe)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Bərpa et',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1d4ed8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NetworkImageBox extends StatelessWidget {
  final String? imageUrl;
  final BorderRadius? borderRadius;

  const _NetworkImageBox({
    required this.imageUrl,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    Widget child;
    if (!hasImage) {
      child = Container(
        color: const Color(0xfff3f4f6),
        child: Icon(
          Icons.image_outlined,
          size: 34,
          color: Colors.grey.shade400,
        ),
      );
    } else {
      child = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            color: const Color(0xfff3f4f6),
            child: Icon(
              Icons.broken_image_outlined,
              size: 34,
              color: Colors.grey.shade400,
            ),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xfff3f4f6),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    }

    if (borderRadius == null) return child;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final double iconSize;

  const _Avatar({
    required this.imageUrl,
    required this.radius,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffe5e7eb),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person,
                size: iconSize,
                color: const Color(0xff6b7280),
              ),
            )
          : Icon(
              Icons.person,
              size: iconSize,
              color: const Color(0xff6b7280),
            ),
    );
  }
}