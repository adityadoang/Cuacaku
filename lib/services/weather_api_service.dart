// File: lib/services/weather_api_service.dart
// Fungsi: Menyediakan layanan komunikasi HTTP GET ke Open-Meteo Weather
// Forecast API dan Open-Meteo Geocoding API beserta penanganan error jaringan.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Exception khusus untuk kesalahan jaringan atau respons Open-Meteo API.
class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  const WeatherApiException(this.message, {this.statusCode});

  /// Mengembalikan pesan error yang mudah dibaca saat exception terjadi.
  @override
  String toString() => message;
}

/// Service REST API untuk Open-Meteo Weather Forecast & Geocoding API (HTTP GET).
class WeatherApiService {
  static const String _forecastHost = 'api.open-meteo.com';
  static const String _geocodingHost = 'geocoding-api.open-meteo.com';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data cuaca terkini, per jam, dan prakiraan 7 hari dari Open-Meteo.
  /// Endpoint: https://api.open-meteo.com/v1/forecast
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      _forecastHost,
      '/v1/forecast',
      {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current': [
          'temperature_2m',
          'relative_humidity_2m',
          'apparent_temperature',
          'is_day',
          'precipitation',
          'weather_code',
          'wind_speed_10m',
        ].join(','),
        'hourly': [
          'temperature_2m',
          'weather_code',
          'precipitation_probability',
          'is_day',
        ].join(','),
        'daily': [
          'weather_code',
          'temperature_2m_max',
          'temperature_2m_min',
          'precipitation_probability_max',
        ].join(','),
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Gagal memuat data cuaca (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const WeatherApiException('Format respons cuaca tidak valid.');
      }

      if (decoded['error'] == true) {
        throw WeatherApiException(
          decoded['reason']?.toString() ?? 'Permintaan cuaca ditolak server.',
        );
      }

      return WeatherData.fromJson(decoded);
    } on SocketException {
      throw const WeatherApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw const WeatherApiException(
        'Koneksi ke server cuaca melebihi batas waktu. Coba lagi nanti.',
      );
    } on FormatException catch (e) {
      throw WeatherApiException('Gagal membaca data cuaca: ${e.message}');
    }
  }

  /// Mencari lokasi kota menggunakan Open-Meteo Geocoding API.
  /// Endpoint: https://geocoding-api.open-meteo.com/v1/search
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const [];
    }

    final uri = Uri.https(
      _geocodingHost,
      '/v1/search',
      {
        'name': trimmed,
        'count': '12',
        'language': 'id',
        'format': 'json',
      },
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Gagal mencari lokasi (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const WeatherApiException('Format respons pencarian tidak valid.');
      }

      final results = decoded['results'];
      if (results is! List) {
        return const [];
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromGeocodingJson)
          .toList();
    } on SocketException {
      throw const WeatherApiException(
        'Tidak ada koneksi internet untuk mencari kota.',
      );
    } on TimeoutException {
      throw const WeatherApiException(
        'Pencarian lokasi melebihi batas waktu. Silakan coba lagi.',
      );
    } on FormatException {
      throw const WeatherApiException(
        'Gagal memproses hasil pencarian lokasi.',
      );
    }
  }

  /// Menutup HTTP client ketika service tidak lagi digunakan.
  void dispose() {
    _client.close();
  }
}
