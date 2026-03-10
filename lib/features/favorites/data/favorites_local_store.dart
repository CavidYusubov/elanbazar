import 'package:shared_preferences/shared_preferences.dart';

class FavoritesLocalStore {
  static const _key = 'guest_favorite_ids';

  Future<List<int>> getIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet()
        .toList();
  }

  Future<void> saveIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();

    final clean = ids
        .where((e) => e > 0)
        .toSet()
        .map((e) => e.toString())
        .toList();

    await prefs.setStringList(_key, clean);
  }

  Future<bool> contains(int adId) async {
    final ids = await getIds();
    return ids.contains(adId);
  }

  Future<bool> toggle(int adId) async {
    final ids = await getIds();
    final list = [...ids];

    if (list.contains(adId)) {
      list.remove(adId);
      await saveIds(list);
      return false;
    } else {
      list.add(adId);
      await saveIds(list);
      return true;
    }
  }

  Future<void> addAll(List<int> ids) async {
    final current = await getIds();
    final merged = {...current, ...ids}.toList();
    await saveIds(merged);
  }

  Future<void> remove(int adId) async {
    final ids = await getIds();
    final list = ids.where((e) => e != adId).toList();
    await saveIds(list);
  }

  Future<void> replaceAll(List<int> ids) async {
    await saveIds(ids);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}