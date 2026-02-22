import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reels_repo.dart';
import '../../../core/models/publisher.dart';
import '../data/models/reel_ad.dart';

final reelsRepoProvider = Provider((ref) => ReelsRepo());

final reelsControllerProvider =
    StateNotifierProvider<ReelsController, ReelsState>((ref) {
  return ReelsController(ref.read(reelsRepoProvider));
});

class ReelsState {
  final bool loading;
  final List<ReelAd> items;
  final Set<int> seenIds;
  final bool hasMore;
  final String? error;

  const ReelsState({
    required this.loading,
    required this.items,
    required this.seenIds,
    required this.hasMore,
    this.error,
  });

  factory ReelsState.initial() =>
      const ReelsState(loading: true, items: [], seenIds: {}, hasMore: true);
}

class ReelsController extends StateNotifier<ReelsState> {
  ReelsController(this._repo) : super(ReelsState.initial()) {
    loadInitial();
  }

  final ReelsRepo _repo;
  bool _busy = false;

  List<ReelAd> _demo() => [
        ReelAd(
          id: 1,
          title: 'Mercedes-Benz E200 (AMG)',
          price: 38500,
          currency: 'AZN',
          coverUrl: 'https://picsum.photos/900/1600?random=21',
          city: 'Bakı',
          category: 'Avtomobil',
          publisher: Publisher(type: 'user', id: 14, name: 'İstifadəçi 4397', avatarUrl: ''),
        ),
        ReelAd(
          id: 2,
          title: 'iPhone 15 Pro Max 256GB',
          price: 2699,
          currency: 'AZN',
          coverUrl: 'https://picsum.photos/900/1600?random=22',
          city: 'Sumqayıt',
          category: 'Telefon',
          publisher: Publisher(type: 'store', id: 8, name: 'Mağaza XYZ', avatarUrl: ''),
        ),
        ReelAd(
          id: 3,
          title: '2 otaqlı mənzil (Nərimanov)',
          price: 650,
          currency: 'AZN',
          coverUrl: 'https://picsum.photos/900/1600?random=23',
          city: 'Bakı',
          category: 'Daşınmaz',
          publisher: Publisher(type: 'user', id: 22, name: 'Digər İstifadəçi', avatarUrl: ''),
        ),
        ReelAd(
          id: 4,
          title: 'PlayStation 5 Slim + 2 joystick',
          price: 999,
          currency: 'AZN',
          coverUrl: 'https://picsum.photos/900/1600?random=24',
          city: 'Gəncə',
          category: 'Elektronika',
          publisher: Publisher(type: 'store', id: 3, name: 'Mağaza ABC', avatarUrl: ''),
        ),
      ];

  Future<void> loadInitial() async {
    // əvvəl demo (UI dərhal açılsın)
    state = ReelsState(
      loading: false,
      items: _demo(),
      seenIds: state.seenIds,
      hasMore: true,
      error: null,
    );

    // sonra API
    try {
      final r = await _repo.fetchReels(exclude: state.seenIds.toList());
      if (r.items.isNotEmpty) {
        state = ReelsState(
          loading: false,
          items: r.items,
          seenIds: state.seenIds,
          hasMore: r.hasMore,
          error: null,
        );
      } else {
        // boş gəldisə demo ilə qal
        state = ReelsState(
          loading: false,
          items: state.items,
          seenIds: state.seenIds,
          hasMore: r.hasMore,
          error: state.error,
        );
      }
    } catch (_) {
      // web-də CORS ola bilər, APK-da normaldır
      state = ReelsState(
        loading: false,
        items: state.items,
        seenIds: state.seenIds,
        hasMore: true,
        error: 'APK-da normaldır (web CORS ola bilər)',
      );
    }
  }

  void markSeen(int id) {
    if (state.seenIds.contains(id)) return;
    state = ReelsState(
      loading: state.loading,
      items: state.items,
      seenIds: {...state.seenIds, id},
      hasMore: state.hasMore,
      error: state.error,
    );
  }

  Future<void> ensureMore(int currentIndex) async {
    if (_busy) return;
    if (!state.hasMore) return;
    if (state.items.length - currentIndex > 4) return;

    _busy = true;
    try {
      final r = await _repo.fetchReels(exclude: state.seenIds.toList());
      if (r.items.isNotEmpty) {
        final merged = [...state.items, ...r.items];

        // memory control: 40 saxla
        final trimmed =
            merged.length > 40 ? merged.sublist(merged.length - 40) : merged;

        state = ReelsState(
          loading: false,
          items: trimmed,
          seenIds: state.seenIds,
          hasMore: r.hasMore,
          error: state.error,
        );
      } else {
        state = ReelsState(
          loading: false,
          items: state.items,
          seenIds: state.seenIds,
          hasMore: r.hasMore,
          error: state.error,
        );
      }
    } catch (_) {
      // sus
    } finally {
      _busy = false;
    }
  }
}