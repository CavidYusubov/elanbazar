import 'ad_comment.dart';

class CommentsPage {
  final List<AdComment> items;
  final int commentCount;
  final bool hasMore;
  final int currentPage;

  CommentsPage({
    required this.items,
    required this.commentCount,
    required this.hasMore,
    required this.currentPage,
  });

  factory CommentsPage.fromJson(Map<String, dynamic> json) {
    final meta = Map<String, dynamic>.from(json['meta'] ?? const {});
    return CommentsPage(
      items: ((json['data'] as List?) ?? const [])
          .map((e) => AdComment.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      hasMore: meta['has_more'] == true,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
    );
  }
}