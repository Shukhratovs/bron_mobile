import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lokal sevimlilar saqlash — backend endpointi yo'q,
/// shuning uchun SharedPreferences'da venue ID'lar saqlanadi.
class FavoritesLocalStorage {
  static const String _key = 'favorite_venue_ids';

  final SharedPreferences _prefs;
  final ValueNotifier<Set<String>> _notifier;

  FavoritesLocalStorage._({required SharedPreferences prefs})
      : _prefs = prefs,
        _notifier = ValueNotifier(
          (prefs.getStringList(_key) ?? []).toSet(),
        );

  static FavoritesLocalStorage? _instance;

  static Future<FavoritesLocalStorage> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = FavoritesLocalStorage._(prefs: prefs);
    return _instance!;
  }

  ValueListenable<Set<String>> get idsListenable => _notifier;

  Set<String> get ids => _notifier.value;

  int get count => _notifier.value.length;

  bool isFavorite(String venueId) => _notifier.value.contains(venueId);

  Future<void> toggle(String venueId) async {
    final current = Set<String>.from(_notifier.value);
    if (current.contains(venueId)) {
      current.remove(venueId);
    } else {
      current.add(venueId);
    }
    await _prefs.setStringList(_key, current.toList());
    _notifier.value = current;
  }

  Future<void> add(String venueId) async {
    if (_notifier.value.contains(venueId)) return;
    final current = Set<String>.from(_notifier.value)..add(venueId);
    await _prefs.setStringList(_key, current.toList());
    _notifier.value = current;
  }

  Future<void> remove(String venueId) async {
    if (!_notifier.value.contains(venueId)) return;
    final current = Set<String>.from(_notifier.value)..remove(venueId);
    await _prefs.setStringList(_key, current.toList());
    _notifier.value = current;
  }
}
