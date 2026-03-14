import 'comment_user.dart';

class AdComment {
  final int id;
  final int adId;
  final int? parentId;
  final String body;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final bool isMine;
  final bool isEdited;
  final String? editedAt;
  final String? createdAt;
  final CommentUser user;
  final List<AdComment> latestReplies;

  AdComment({
    required this.id,
    required this.adId,
    required this.parentId,
    required this.body,
    required this.likesCount,
    required this.repliesCount,
    required this.isLiked,
    required this.isMine,
    required this.isEdited,
    required this.editedAt,
    required this.createdAt,
    required this.user,
    required this.latestReplies,
  });

  factory AdComment.fromJson(Map<String, dynamic> json) {
    return AdComment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      adId: (json['ad_id'] as num?)?.toInt() ?? 0,
      parentId: (json['parent_id'] as num?)?.toInt(),
      body: (json['body'] ?? '').toString(),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] == true,
      isMine: json['is_mine'] == true,
      isEdited: json['is_edited'] == true,
      editedAt: json['edited_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      user: CommentUser.fromJson(
        Map<String, dynamic>.from(json['user'] ?? const {}),
      ),
      latestReplies: ((json['latest_replies'] as List?) ?? const [])
          .map((e) => AdComment.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  AdComment copyWith({
    int? likesCount,
    bool? isLiked,
    String? body,
    bool? isEdited,
    List<AdComment>? latestReplies,
    int? repliesCount,
  }) {
    return AdComment(
      id: id,
      adId: adId,
      parentId: parentId,
      body: body ?? this.body,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isLiked: isLiked ?? this.isLiked,
      isMine: isMine,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt,
      createdAt: createdAt,
      user: user,
      latestReplies: latestReplies ?? this.latestReplies,
    );
  }
}