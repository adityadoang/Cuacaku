// File: lib/viewmodels/weather_viewmodel.dart
// Fungsi: ViewModel (MVVM) untuk HomeScreen yang mengelola state cuaca,
// pemilihan lokasi aktif, pengambilan data API, dan daftar lokasi favorit.

import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/hive_storage_service.dart';
import '../services/weather_api_service.dart';

/// Status tampilan data cuaca pada [HomeScreen].
enum WeatherViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel utama (MVVM) untuk Home / Weather Screen.
/// Mengelola state cuaca terkini, lokasi aktif, dan daftar favorit Hive.
class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final HiveStorageService _storageService;

  WeatherViewState _state = WeatherViewState.initial;
  LocationModel _selectedLocation = LocationModel.defaultLocation;
  WeatherData? _weatherData;
  List<LocationModel> _favorites = const [];
  String? _errorMessage;

  WeatherViewModel({
    required WeatherApiService apiService,
    required HiveStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  WeatherViewState get state => _state;
  LocationModel get selectedLocation => _selectedLocation;
  WeatherData? get weatherData => _weatherData;
  List<LocationModel> get favorites => _favorites;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == WeatherViewState.loading;

  /// Mengecek apakah suatu [location] termasuk dalam daftar favorit.
  bool isFavorite(LocationModel location) {
    return _storageService.isFavorite(location);
  }

  bool get isSelectedLocationFavorite => isFavorite(_selectedLocation);

  /// Memuat lokasi tersimpan & daftar favorit dari Hive, lalu mengambil cuaca live.
  Future<void> initialize() async {
    _selectedLocation = _storageService.getSelectedLocation();
    _favorites = _storageService.getFavorites();
    notifyListeners();
    await fetchWeatherForSelectedLocation();
  }

  /// Mengganti kota aktif, menyimpannya ke Hive, lalu mengambil data cuaca dari API.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await _storageService.saveSelectedLocation(location);
    notifyListeners();
    await fetchWeatherForSelectedLocation();
  }

  /// Mengambil data cuaca terkini & prakiraan dari Open-Meteo API.
  Future<void> fetchWeatherForSelectedLocation() async {
    _state = WeatherViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.fetchWeather(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );

      if (result.daily.isEmpty && result.hourly.isEmpty) {
        _weatherData = null;
        _state = WeatherViewState.empty;
      } else {
        _weatherData = result;
        _state = WeatherViewState.loaded;
      }
    } on WeatherApiException catch (e) {
      _errorMessage = e.message;
      _state = WeatherViewState.error;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan tak terduga saat memuat data cuaca.';
      _state = WeatherViewState.error;
    }

    notifyListeners();
  }

  /// Menambah atau menghapus lokasi dari daftar favorit Hive.
  Future<bool> toggleFavorite(LocationModel location) async {
    final added = await _storageService.toggleFavorite(location);
    _favorites = _storageService.getFavorites();
    notifyListeners();
    return added;
  }
}
