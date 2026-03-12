String? _absUrl(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;

  if (s.startsWith('http://') || s.startsWith('https://')) {
    return s;
  }

  if (s.startsWith('/')) {
    return 'https://avtoal.az$s';
  }

  return s;
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

class MessagePartnerStore {
  final int id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? phone;

  MessagePartnerStore({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.phone,
  });

  factory MessagePartnerStore.fromJson(Map<String, dynamic> json) {
    return MessagePartnerStore(
      id: _asInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      logoUrl: _absUrl(json['logo_url']),
      phone: json['phone']?.toString(),
    );
  }
}

class MessagePartner {
  final int id;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final bool isOnline;
  final String? lastSeenHuman;
  final MessagePartnerStore? store;

  MessagePartner({
    required this.id,
    required this.name,
    this.phone,
    this.avatarUrl,
    required this.isOnline,
    this.lastSeenHuman,
    this.store,
  });

  factory MessagePartner.fromJson(Map<String, dynamic> json) {
    return MessagePartner(
      id: _asInt(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      phone: json['phone']?.toString(),
      avatarUrl: _absUrl(json['avatar_url']),
      isOnline: json['is_online'] == true,
      lastSeenHuman: json['last_seen_human']?.toString(),
      store: json['store'] is Map
          ? MessagePartnerStore.fromJson(
              Map<String, dynamic>.from(json['store']),
            )
          : null,
    );
  }
}

class MessageAdMini {
  final int id;
  final String title;
  final num? price;
  final String? currency;
  final String? priceFormatted;
  final String? imageUrl;
  final String? city;

  MessageAdMini({
    required this.id,
    required this.title,
    this.price,
    this.currency,
    this.priceFormatted,
    this.imageUrl,
    this.city,
  });

  factory MessageAdMini.fromJson(Map<String, dynamic> json) {
    return MessageAdMini(
      id: _asInt(json['id']) ?? 0,
      title: (json['title'] ?? '').toString(),
      price: _asNum(json['price']),
      currency: json['currency']?.toString(),
      priceFormatted: json['price_formatted']?.toString(),
      imageUrl: _absUrl(json['image_url']),
      city: json['city']?.toString(),
    );
  }
}

class MessageLastMessage {
  final int id;
  final String? body;
  final String? imageUrl;
  final String preview;
  final bool isRead;
  final String? readAt;
  final String? createdAt;
  final String? timeLabel;

  MessageLastMessage({
    required this.id,
    this.body,
    this.imageUrl,
    required this.preview,
    required this.isRead,
    this.readAt,
    this.createdAt,
    this.timeLabel,
  });

  factory MessageLastMessage.fromJson(Map<String, dynamic> json) {
    return MessageLastMessage(
      id: _asInt(json['id']) ?? 0,
      body: json['body']?.toString(),
      imageUrl: _absUrl(json['image_url']),
      preview: (json['preview'] ?? '').toString(),
      isRead: json['is_read'] == true,
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      timeLabel: json['time_label']?.toString(),
    );
  }
}

class MessageThreadMeta {
  final int partnerId;
  final int? adId;
  final String threadType;
  final int unreadCount;
  final MessageLastMessage lastMessage;

  MessageThreadMeta({
    required this.partnerId,
    this.adId,
    required this.threadType,
    required this.unreadCount,
    required this.lastMessage,
  });

  factory MessageThreadMeta.fromJson(Map<String, dynamic> json) {
    return MessageThreadMeta(
      partnerId: _asInt(json['partner_id']) ?? 0,
      adId: _asInt(json['ad_id']),
      threadType: (json['thread_type'] ?? 'all').toString(),
      unreadCount: _asInt(json['unread_count']) ?? 0,
      lastMessage: MessageLastMessage.fromJson(
        Map<String, dynamic>.from(json['last_message']),
      ),
    );
  }
}

class MessageThreadListItem {
  final MessagePartner partner;
  final MessageThreadMeta thread;
  final MessageAdMini? ad;

  MessageThreadListItem({
    required this.partner,
    required this.thread,
    this.ad,
  });

  factory MessageThreadListItem.fromJson(Map<String, dynamic> json) {
    return MessageThreadListItem(
      partner: MessagePartner.fromJson(
        Map<String, dynamic>.from(json['partner']),
      ),
      thread: MessageThreadMeta.fromJson(
        Map<String, dynamic>.from(json['thread']),
      ),
      ad: json['ad'] is Map
          ? MessageAdMini.fromJson(Map<String, dynamic>.from(json['ad']))
          : null,
    );
  }
}

class MessageItem {
  final int id;
  final int senderId;
  final int receiverId;
  final int? adId;
  final String? body;
  final String? imageUrl;
  final bool isSpam;
  final bool isRead;
  final String? readAt;
  final String? createdAt;
  final String? timeLabel;
  final bool isMe;
  final bool isSent;
  final bool isReadByOther;

  MessageItem({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.adId,
    this.body,
    this.imageUrl,
    required this.isSpam,
    required this.isRead,
    this.readAt,
    this.createdAt,
    this.timeLabel,
    required this.isMe,
    required this.isSent,
    required this.isReadByOther,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    final ticks = json['ticks'] is Map
        ? Map<String, dynamic>.from(json['ticks'])
        : <String, dynamic>{};

    return MessageItem(
      id: _asInt(json['id']) ?? 0,
      senderId: _asInt(json['sender_id']) ?? 0,
      receiverId: _asInt(json['receiver_id']) ?? 0,
      adId: _asInt(json['ad_id']),
      body: json['body']?.toString(),
      imageUrl: _absUrl(json['image_url']),
      isSpam: json['is_spam'] == true,
      isRead: json['is_read'] == true,
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      timeLabel: json['time_label']?.toString(),
      isMe: json['is_me'] == true,
      isSent: ticks['sent'] == true,
      isReadByOther: ticks['read'] == true,
    );
  }
}

class MessageThreadHeader {
  final MessagePartner partner;
  final MessageAdMini? ad;
  final String threadType;
  final bool isBlocked;
  final int lastId;

  MessageThreadHeader({
    required this.partner,
    this.ad,
    required this.threadType,
    required this.isBlocked,
    required this.lastId,
  });

  factory MessageThreadHeader.fromJson(Map<String, dynamic> json) {
    return MessageThreadHeader(
      partner: MessagePartner.fromJson(
        Map<String, dynamic>.from(json['partner']),
      ),
      ad: json['ad'] is Map
          ? MessageAdMini.fromJson(Map<String, dynamic>.from(json['ad']))
          : null,
      threadType: (json['thread_type'] ?? 'all').toString(),
      isBlocked: json['is_blocked'] == true,
      lastId: _asInt(json['last_id']) ?? 0,
    );
  }
}

class MessageThreadDetail {
  final MessageThreadHeader thread;
  final List<MessageItem> messages;
  final int lastId;

  MessageThreadDetail({
    required this.thread,
    required this.messages,
    required this.lastId,
  });
}