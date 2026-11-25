// File: lib/main.dart
// Fungsi: Titik masuk utama (entry point) aplikasi CuacaKu untuk inisialisasi
// layanan penyimpanan Hive, service API, serta mendaftarkan Provider MVVM.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/hive_storage_service.dart';
import 'services/weather_api_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

/// Fungsi utama aplikasi yang menginisialisasi binding Flutter, Hive storage,
/// serta service API sebelum menjalankan widget root [WeatherResponsiApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = HiveStorageService();
  await storageService.init();

  final apiService = WeatherApiService();

  runApp(
    WeatherResponsiApp(
      apiService: apiService,
      storageService: storageService,
    ),
  );
}

/// Widget root aplikasi yang membungkus seluruh pohon widget dengan
/// [MultiProvider] untuk state management MVVM dan tema Material Design 3.
class WeatherResponsiApp extends StatelessWidget {
  final WeatherApiService apiService;
  final HiveStorageService storageService;

  const WeatherResponsiApp({
    super.key,
    required this.apiService,
    required this.storageService,
  });

  /// Membangun konfigurasi [MultiProvider] dan [MaterialApp] dengan halaman awal [HomeScreen].
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(
            apiService: apiService,
            storageService: storageService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'CuacaKu - Responsi Flutter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
