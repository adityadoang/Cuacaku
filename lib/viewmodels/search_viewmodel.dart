// File: lib/viewmodels/search_viewmodel.dart
// Fungsi: ViewModel (MVVM) untuk SearchScreen yang mengelola pencarian kota
// via Open-Meteo Geocoding API (dengan debounce) serta riwayat pencarian Hive.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/hive_storage_service.dart';
import '../services/weather_api_service.dart';

/// Status tampilan pencarian lokasi pada [SearchScreen].
enum SearchViewState {
  idle,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel (MVVM) untuk Search / Location Screen.
/// Mengelola pencarian kota melalui Open-Meteo Geocoding API & riwayat Hive.
class SearchViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final HiveStorageService _storageService;

  SearchViewState _state = SearchViewState.idle;
  List<LocationModel> _results = const [];
  List<LocationModel> _history = const [];
  String? _errorMessage;
  Timer? _debounceTimer;

  SearchViewModel({
    required WeatherApiService apiService,
    required HiveStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  SearchViewState get state => _state;
  List<LocationModel> get results => _results;
  List<LocationModel> get history => _history;
  String? get errorMessage => _errorMessage;

  /// Memuat daftar riwayat pencarian kota dari Hive storage.
  void loadHistory() {
    _history = _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Menangani perubahan teks pencarian dengan debounce 450ms agar hemat request API.
  void onQueryChanged(String value) {
    _debounceTimer?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _state = SearchViewState.idle;
      _results = const [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    if (trimmed.length < 2) {
      _state = SearchViewState.idle;
      _results = const [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      searchCities(trimmed);
    });
  }

  /// Menjalankan HTTP GET ke Open-Meteo Geocoding API.
  Future<void> searchCities(String rawQuery) async {
    final trimmed = rawQuery.trim();

    if (trimmed.length < 2) {
      _state = SearchViewState.idle;
      _results = const [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _state = SearchViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final matches = await _apiService.searchLocations(trimmed);
      _results = matches;
      _state =
          matches.isEmpty ? SearchViewState.empty : SearchViewState.loaded;
    } on WeatherApiException catch (e) {
      _errorMessage = e.message;
      _results = const [];
      _state = SearchViewState.error;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat mencari lokasi.';
      _results = const [];
      _state = SearchViewState.error;
    }

    notifyListeners();
  }

  /// Menghapus hasil pencarian sementara dan mereset state pencarian ke idle.
  void clearSearch() {
    _debounceTimer?.cancel();
    _results = const [];
    _errorMessage = null;
    _state = SearchViewState.idle;
    notifyListeners();
  }

  /// Menyimpan [location] yang dipilih ke dalam riwayat pencarian Hive.
  Future<void> saveToHistory(LocationModel location) async {
    await _storageService.addToSearchHistory(location);
    _history = _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Menghapus satu [location] dari riwayat pencarian Hive.
  Future<void> removeHistoryItem(LocationModel location) async {
    await _storageService.removeFromSearchHistory(location);
    _history = _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Menghapus seluruh riwayat pencarian kota dari Hive.
  Future<void> clearAllHistory() async {
    await _storageService.clearSearchHistory();
    _history = const [];
    notifyListeners();
  }

  /// Membatalkan timer debounce sebelum ViewModel dibuang dari memori.
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
