class AccountResponse {
  final AccountUser user;
  final double balance;
  final int followingCount;
  final int followersCount;
  final AccountCounts counts;
  final List<AccountMenuItem> walletMenu;

  const AccountResponse({
    required this.user,
    required this.balance,
    required this.followingCount,
    required this.followersCount,
    required this.counts,
    required this.walletMenu,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    return AccountResponse(
      user: AccountUser.fromJson(Map<String, dynamic>.from(json['user'] ?? {})),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      counts: AccountCounts.fromJson(Map<String, dynamic>.from(json['counts'] ?? {})),
      walletMenu: ((json['wallet_menu'] as List?) ?? [])
          .map((e) => AccountMenuItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class AccountUser {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String? createdAtHuman;
  final AccountStoreMini? store;

  const AccountUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.createdAtHuman,
    this.store,
  });

  factory AccountUser.fromJson(Map<String, dynamic> json) {
    return AccountUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      createdAtHuman: json['created_at_human']?.toString(),
      store: json['store'] is Map
          ? AccountStoreMini.fromJson(Map<String, dynamic>.from(json['store']))
          : null,
    );
  }
}

class AccountStoreMini {
  final int id;
  final String name;
  final String slug;

  const AccountStoreMini({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory AccountStoreMini.fromJson(Map<String, dynamic> json) {
    return AccountStoreMini(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }
}

class AccountCounts {
  final int live;
  final int expired;
  final int pending;
  final int rejected;
  final int archive;

  const AccountCounts({
    required this.live,
    required this.expired,
    required this.pending,
    required this.rejected,
    required this.archive,
  });

  factory AccountCounts.fromJson(Map<String, dynamic> json) {
    return AccountCounts(
      live: (json['live'] as num?)?.toInt() ?? 0,
      expired: (json['expired'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      archive: (json['archive'] as num?)?.toInt() ?? 0,
    );
  }
}

class AccountMenuItem {
  final String key;
  final String title;
  final String icon;

  const AccountMenuItem({
    required this.key,
    required this.title,
    required this.icon,
  });

  factory AccountMenuItem.fromJson(Map<String, dynamic> json) {
    return AccountMenuItem(
      key: (json['key'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
    );
  }
}

class AccountAdItem {
  final int id;
  final String title;
  final String priceFormatted;
  final String currency;
  final String? coverUrl;
  final String? city;
  final String? publishedAtShort;
  final bool isVip;
  final bool isPremium;
  final String status;

  const AccountAdItem({
    required this.id,
    required this.title,
    required this.priceFormatted,
    required this.currency,
    this.coverUrl,
    this.city,
    this.publishedAtShort,
    required this.isVip,
    required this.isPremium,
    required this.status,
  });

  factory AccountAdItem.fromJson(Map<String, dynamic> json) {
    return AccountAdItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      priceFormatted: (json['price_formatted'] ?? '0').toString(),
      currency: (json['currency'] ?? 'AZN').toString(),
      coverUrl: json['cover_url']?.toString(),
      city: json['city']?.toString(),
      publishedAtShort: json['published_at_short']?.toString(),
      isVip: json['is_vip'] == true,
      isPremium: json['is_premium'] == true,
      status: (json['status'] ?? '').toString(),
    );
  }
}


class FollowListResponse {
  final List<FollowItem> items;
  final PaginationMeta pagination;

  const FollowListResponse({
    required this.items,
    required this.pagination,
  });

  factory FollowListResponse.fromJson(Map<String, dynamic> json) {
    return FollowListResponse(
      items: ((json['items'] as List?) ?? [])
          .map((e) => FollowItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pagination: PaginationMeta.fromJson(
        Map<String, dynamic>.from(json['pagination'] ?? {}),
      ),
    );
  }
}

class FollowItem {
  final int id;
  final String type;
  final FollowTarget target;
  final String? createdAt;

  const FollowItem({
    required this.id,
    required this.type,
    required this.target,
    this.createdAt,
  });

  factory FollowItem.fromJson(Map<String, dynamic> json) {
    return FollowItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] ?? '').toString(),
      target: FollowTarget.fromJson(
        Map<String, dynamic>.from(json['target'] ?? {}),
      ),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class FollowTarget {
  final int id;
  final String name;
  final String? slug;
  final String? photoUrl;

  const FollowTarget({
    required this.id,
    required this.name,
    this.slug,
    this.photoUrl,
  });

  factory FollowTarget.fromJson(Map<String, dynamic> json) {
    return FollowTarget(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class WalletResponse {
  final WalletData wallet;
  final double total;

  const WalletResponse({
    required this.wallet,
    required this.total,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      wallet: WalletData.fromJson(
        Map<String, dynamic>.from(json['wallet'] ?? {}),
      ),
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WalletData {
  final int id;
  final int userId;
  final double mainBalance;
  final double bonusBalance;
  final double packageBalance;
  final int adBalance;

  const WalletData({
    required this.id,
    required this.userId,
    required this.mainBalance,
    required this.bonusBalance,
    required this.packageBalance,
    required this.adBalance,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      mainBalance: (json['main_balance'] as num?)?.toDouble() ?? 0,
      bonusBalance: (json['bonus_balance'] as num?)?.toDouble() ?? 0,
      packageBalance: (json['package_balance'] as num?)?.toDouble() ?? 0,
      adBalance: (json['ad_balance'] as num?)?.toInt() ?? 0,
    );
  }
}

class WalletTransactionsResponse {
  final String tab;
  final List<WalletTransactionItem> items;
  final PaginationMeta pagination;

  const WalletTransactionsResponse({
    required this.tab,
    required this.items,
    required this.pagination,
  });

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsResponse(
      tab: (json['tab'] ?? 'personal').toString(),
      items: ((json['items'] as List?) ?? [])
          .map((e) => WalletTransactionItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pagination: PaginationMeta.fromJson(
        Map<String, dynamic>.from(json['pagination'] ?? {}),
      ),
    );
  }
}

class WalletTransactionItem {
  final int id;
  final String scope;
  final String type;
  final String? title;
  final String? refNo;
  final double amount;
  final String currency;
  final String? status;
  final String? createdAtHuman;

  const WalletTransactionItem({
    required this.id,
    required this.scope,
    required this.type,
    this.title,
    this.refNo,
    required this.amount,
    required this.currency,
    this.status,
    this.createdAtHuman,
  });

  factory WalletTransactionItem.fromJson(Map<String, dynamic> json) {
    return WalletTransactionItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      scope: (json['scope'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: json['title']?.toString(),
      refNo: json['ref_no']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? 'AZN').toString(),
      status: json['status']?.toString(),
      createdAtHuman: json['created_at_human']?.toString(),
    );
  }
}

class LimitItem {
  final int id;
  final String name;
  final String? slug;
  final int? parentId;
  final String? parentName;
  final int freeLimit;
  final int paidLimit;
  final int freeUsed;
  final int paidUsed;
  final int freeRemaining;
  final int paidRemaining;
  final int remainingTotal;

  const LimitItem({
    required this.id,
    required this.name,
    this.slug,
    this.parentId,
    this.parentName,
    required this.freeLimit,
    required this.paidLimit,
    required this.freeUsed,
    required this.paidUsed,
    required this.freeRemaining,
    required this.paidRemaining,
    required this.remainingTotal,
  });

  factory LimitItem.fromJson(Map<String, dynamic> json) {
    return LimitItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
      parentId: (json['parent_id'] as num?)?.toInt(),
      parentName: json['parent_name']?.toString(),
      freeLimit: (json['free_limit'] as num?)?.toInt() ?? 0,
      paidLimit: (json['paid_limit'] as num?)?.toInt() ?? 0,
      freeUsed: (json['free_used'] as num?)?.toInt() ?? 0,
      paidUsed: (json['paid_used'] as num?)?.toInt() ?? 0,
      freeRemaining: (json['free_remaining'] as num?)?.toInt() ?? 0,
      paidRemaining: (json['paid_remaining'] as num?)?.toInt() ?? 0,
      remainingTotal: (json['remaining_total'] as num?)?.toInt() ?? 0,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasMore: json['has_more'] == true,
    );
  }
}