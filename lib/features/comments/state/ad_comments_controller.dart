import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/comments_repo.dart';
import '../models/ad_comment.dart';

final commentsRepoProvider = Provider<CommentsRepo>((ref) {
  return CommentsRepo(ApiClient.I);
});

class AdCommentsState {
  final bool loading;
  final bool loadingMore;
  final bool posting;
  final List<AdComment> items;
  final int totalCount;
  final int page;
  final bool hasMore;
  final String? error;

  const AdCommentsState({
    this.loading = true,
    this.loadingMore = false,
    this.posting = false,
    this.items = const [],
    this.totalCount = 0,
    this.page = 1,
    this.hasMore = true,
    this.error,
  });

  AdCommentsState copyWith({
    bool? loading,
    bool? loadingMore,
    bool? posting,
    List<AdComment>? items,
    int? totalCount,
    int? page,
    bool? hasMore,
    String? error,
  }) {
    return AdCommentsState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      posting: posting ?? this.posting,
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class AdCommentsController extends StateNotifier<AdCommentsState> {
  AdCommentsController(this._repo, this.adId) : super(const AdCommentsState()) {
    loadInitial();
  }

  final CommentsRepo _repo;
  final int adId;

  Future<void> loadInitial() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final pageData = await _repo.fetchComments(adId, page: 1);
      state = state.copyWith(
        loading: false,
        items: pageData.items,
        totalCount: pageData.commentCount,
        page: pageData.currentPage,
        hasMore: pageData.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;

    state = state.copyWith(loadingMore: true);
    try {
      final nextPage = state.page + 1;
      final pageData = await _repo.fetchComments(adId, page: nextPage);

      state = state.copyWith(
        loadingMore: false,
        items: [...state.items, ...pageData.items],
        totalCount: pageData.commentCount,
        page: pageData.currentPage,
        hasMore: pageData.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        loadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> postComment(String text, {int? parentId}) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    state = state.copyWith(posting: true, error: null);

    try {
      final item = await _repo.createComment(
        adId: adId,
        body: clean,
        parentId: parentId,
      );

      if (parentId == null) {
        state = state.copyWith(
          posting: false,
          totalCount: state.totalCount + 1,
          items: [item, ...state.items],
        );
      } else {
        final updated = state.items.map((c) {
          if (c.id != parentId) return c;
          return c.copyWith(
            repliesCount: c.repliesCount + 1,
            latestReplies: [item, ...c.latestReplies],
          );
        }).toList();

        state = state.copyWith(
          posting: false,
          totalCount: state.totalCount + 1,
          items: updated,
        );
      }
    } catch (e) {
      state = state.copyWith(
        posting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> toggleLike(int commentId) async {
    final idx = state.items.indexWhere((e) => e.id == commentId);
    if (idx == -1) return;

    final current = state.items[idx];
    final optimistic = current.copyWith(
      isLiked: !current.isLiked,
      likesCount: current.isLiked
          ? (current.likesCount > 0 ? current.likesCount - 1 : 0)
          : current.likesCount + 1,
    );

    final list = [...state.items];
    list[idx] = optimistic;
    state = state.copyWith(items: list);

    try {
      final res = await _repo.toggleLike(commentId);

      list[idx] = current.copyWith(
        isLiked: res['liked'] == true,
        likesCount: (res['likes_count'] as num?)?.toInt() ?? current.likesCount,
      );

      state = state.copyWith(items: [...list]);
    } catch (_) {
      list[idx] = current;
      state = state.copyWith(items: [...list]);
    }
  }

  Future<void> deleteComment(int commentId) async {
    await _repo.deleteComment(commentId);

    state = state.copyWith(
      items: state.items.where((e) => e.id != commentId).toList(),
      totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
    );
  }
}

final adCommentsControllerProvider = StateNotifierProvider.family<
    AdCommentsController, AdCommentsState, int>((ref, adId) {
  final repo = ref.watch(commentsRepoProvider);
  return AdCommentsController(repo, adId);
});