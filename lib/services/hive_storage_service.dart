// File: lib/services/hive_storage_service.dart
// Fungsi: Mengelola penyimpanan lokal berbasis Hive untuk lokasi aktif,
// daftar lokasi favorit, dan riwayat pencarian kota.

import 'package:hive_flutter/hive_flutter.dart';

import '../models/location_model.dart';

/// Service Local Storage berbasis Hive untuk menyimpan:
/// 1. Daftar lokasi favorit (`favorites_box`)
/// 2. Riwayat pencarian lokasi (`search_history_box`)
/// 3. Lokasi terakhir yang dipilih (`selected_location_box`)
class HiveStorageService {
  static const String _favoritesBoxName = 'favorites_box';
  static const String _historyBoxName = 'search_history_box';
  static const String _selectedLocationBoxName = 'selected_location_box';
  static const String _selectedKey = 'active_location';
  static const int _maxHistoryItems = 10;

  late Box<LocationModel> _favoritesBox;
  late Box<LocationModel> _historyBox;
  late Box<LocationModel> _selectedLocationBox;

  bool _isInitialized = false;

  /// Inisialisasi Hive, registrasi TypeAdapter, dan membuka seluruh box.
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LocationModelAdapter());
    }

    _favoritesBox = await Hive.openBox<LocationModel>(_favoritesBoxName);
    _historyBox = await Hive.openBox<LocationModel>(_historyBoxName);
    _selectedLocationBox =
        await Hive.openBox<LocationModel>(_selectedLocationBoxName);

    _isInitialized = true;
  }

  // ---------------------------------------------------------------------------
  // LOKASI TERPILIH (LAST SELECTED)
  // ---------------------------------------------------------------------------

  /// Mengambil lokasi terakhir yang dipilih pengguna (default: Jakarta).
  LocationModel getSelectedLocation() {
    return _selectedLocationBox.get(_selectedKey) ??
        LocationModel.defaultLocation;
  }

  /// Menyimpan lokasi aktif yang dipilih pengguna ke dalam Hive.
  Future<void> saveSelectedLocation(LocationModel location) async {
    await _selectedLocationBox.put(_selectedKey, location);
  }

  // ---------------------------------------------------------------------------
  // LOKASI FAVORIT
  // ---------------------------------------------------------------------------

  /// Mengambil seluruh daftar lokasi favorit dengan urutan terbaru di atas.
  List<LocationModel> getFavorites() {
    return _favoritesBox.values.toList().reversed.toList();
  }

  /// Mengecek apakah suatu [location] sudah tersimpan di daftar favorit.
  bool isFavorite(LocationModel location) {
    return _favoritesBox.containsKey(location.storageKey);
  }

  /// Menambahkan [location] ke dalam daftar favorit Hive.
  Future<void> addFavorite(LocationModel location) async {
    await _favoritesBox.put(location.storageKey, location);
  }

  /// Menghapus [location] dari daftar favorit Hive.
  Future<void> removeFavorite(LocationModel location) async {
    await _favoritesBox.delete(location.storageKey);
  }

  /// Mengubah status favorit (menambah jika belum ada, menghapus jika sudah ada).
  Future<bool> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      await removeFavorite(location);
      return false;
    } else {
      await addFavorite(location);
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // RIWAYAT PENCARIAN
  // ---------------------------------------------------------------------------

  /// Mengambil daftar riwayat pencarian kota (terbaru di urutan paling atas).
  List<LocationModel> getSearchHistory() {
    return _historyBox.values.toList().reversed.toList();
  }

  /// Menyimpan lokasi ke riwayat pencarian (tanpa duplikasi, terbaru di atas).
  Future<void> addToSearchHistory(LocationModel location) async {
    final existing = _historyBox.values
        .where((item) => item.storageKey != location.storageKey)
        .toList();

    existing.add(location);

    // Batasi maksimal 10 riwayat terbaru.
    final trimmed = existing.length > _maxHistoryItems
        ? existing.sublist(existing.length - _maxHistoryItems)
        : existing;

    await _historyBox.clear();
    for (final item in trimmed) {
      await _historyBox.add(item);
    }
  }

  /// Menghapus satu item [location] dari riwayat pencarian.
  Future<void> removeFromSearchHistory(LocationModel location) async {
    final remaining = _historyBox.values
        .where((item) => item.storageKey != location.storageKey)
        .toList();

    await _historyBox.clear();
    for (final item in remaining) {
      await _historyBox.add(item);
    }
  }

  /// Menghapus seluruh riwayat pencarian yang tersimpan di Hive.
  Future<void> clearSearchHistory() async {
    await _historyBox.clear();
  }
}
