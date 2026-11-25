// File: lib/views/home_screen.dart
// Fungsi: Halaman utama aplikasi cuaca yang menampilkan latar pemandangan
// parallax, suhu terkini, prakiraan per jam, detail metrik, dan prakiraan 7 hari.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_code_helper.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/hourly_forecast_strip.dart';
import '../widgets/scenic_landscape_background.dart';
import '../widgets/wave_bottom_sheet.dart';
import '../widgets/weather_details_section.dart';
import 'search_screen.dart';

/// Screen 1: Home / Weather Screen (StatefulWidget).
/// Menggunakan CustomScrollView + SliverAppBar (parallax) agar gambar pemandangan
/// ikut bergulir dengan halus saat scroll, dilengkapi pull-to-refresh dan
/// panel gelombang "Weather Today" yang nyaman digulir dalam satu alur.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Menginisialisasi data cuaca awal setelah frame pertama dirender.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeatherViewModel>().initialize();
    });
  }

  /// Membuka halaman pencarian dan pemilihan lokasi ([SearchScreen]).
  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  /// Menambah atau menghapus lokasi aktif dari daftar favorit lalu menampilkan SnackBar.
  Future<void> _toggleCurrentFavorite(WeatherViewModel vm) async {
    final added = await vm.toggleFavorite(vm.selectedLocation);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${vm.selectedLocation.name} ditambahkan ke lokasi favorit'
              : '${vm.selectedLocation.name} dihapus dari lokasi favorit',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Menentukan warna bar atas saat header menciut (collapsed) sesuai kondisi cuaca.
  Color _collapsedBarColor(int weatherCode, bool isDay) {
    final category = WeatherCodeHelper.getCategory(weatherCode);
    if (category == WeatherCategory.rain ||
        category == WeatherCategory.drizzle ||
        category == WeatherCategory.thunderstorm ||
        category == WeatherCategory.snow) {
      return const Color(0xFF425C87);
    }
    if (!isDay) {
      return const Color(0xFF3E56C4);
    }
    if (category == WeatherCategory.cloudy || category == WeatherCategory.fog) {
      return const Color(0xFF5D85BD);
    }
    return const Color(0xFF5B9CF6);
  }

  /// Membangun tampilan utama dengan [RefreshIndicator] dan [CustomScrollView].
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topPadding = MediaQuery.paddingOf(context).top;
    final expandedHeight = (screenHeight * 0.62).clamp(400.0, 540.0);
    const toolbarHeight = 64.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceWhite,
        body: Consumer<WeatherViewModel>(
          builder: (context, vm, _) {
            final weather = vm.weatherData;
            final weatherCode = weather?.current.weatherCode ?? 0;
            final isDay = weather?.current.isDay ?? true;
            final barColor = _collapsedBarColor(weatherCode, isDay);

            return RefreshIndicator(
              color: AppTheme.primarySky,
              backgroundColor: AppTheme.surfaceWhite,
              edgeOffset: topPadding + toolbarHeight,
              onRefresh: () => vm.fetchWeatherForSelectedLocation(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    stretch: true,
                    expandedHeight: expandedHeight,
                    toolbarHeight: toolbarHeight,
                    automaticallyImplyLeading: false,
                    backgroundColor: barColor,
                    elevation: 0,
                    scrolledUnderElevation: 2,
                    surfaceTintColor: Colors.transparent,
                    titleSpacing: 0,
                    title: _buildPinnedTopBar(context, vm, weather),
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final minExtent = topPadding + toolbarHeight;
                        final maxExtent = expandedHeight + topPadding;
                        final currentExtent = constraints.maxHeight;
                        final collapseFraction = ((maxExtent - currentExtent) /
                                (maxExtent - minExtent).clamp(1.0, double.infinity))
                            .clamp(0.0, 1.0);
                        final heroOpacity =
                            (1.0 - collapseFraction * 1.45).clamp(0.0, 1.0);

                        return FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Gambar latar ikut bergerak (parallax) saat scroll
                              ScenicLandscapeBackground(
                                weatherCode: weatherCode,
                                isDay: isDay,
                              ),
                              // Gradient halus di atas agar teks header tetap kontras
                              const Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 150,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0x4D0F1E3A),
                                        Color(0x000F1E3A),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Hero suhu & kondisi yang memudar halus saat di-scroll
                              SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: toolbarHeight + 4,
                                  ),
                                  child: Opacity(
                                    opacity: heroOpacity,
                                    child: _buildHeroSection(
                                      context,
                                      vm,
                                      weather,
                                    ),
                                  ),
                                ),
                              ),
                              // Gelombang putih mulus menyambung ke panel bawah
                              Positioned(
                                bottom: -1,
                                left: 0,
                                right: 0,
                                height: 28,
                                child: ClipPath(
                                  clipper: const WaveTopClipper(),
                                  child: Container(
                                    color: AppTheme.surfaceWhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppTheme.surfaceWhite,
                      child: _buildSheetContent(context, vm, weather),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Membangun bar atas yang tetap menempel (pinned) berisi nama kota, tanggal,
  /// badge suhu ringkas, tombol favorit, muat ulang, dan menu pencarian.
  Widget _buildPinnedTopBar(
    BuildContext context,
    WeatherViewModel vm,
    WeatherData? weather,
  ) {
    final location = vm.selectedLocation;
    final dateText = weather != null
        ? DateFormatter.formatHeroDateTime(weather.current.time)
        : DateFormatter.formatHeroDateTime(DateTime.now());
    final isFav = vm.isSelectedLocationFavorite;
    final tempBadge =
        weather != null ? '${weather.current.temperature.round()}°' : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: _openSearchScreen,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (tempBadge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x2EFFFFFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tempBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        dateText,
                        style: const TextStyle(
                          color: Color(0xE0FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: isFav ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
            onPressed: () => _toggleCurrentFavorite(vm),
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? const Color(0xFFFF7A8A) : Colors.white,
              size: 22,
            ),
          ),
          IconButton(
            tooltip: 'Muat Ulang Cuaca',
            onPressed: vm.isLoading
                ? null
                : () => vm.fetchWeatherForSelectedLocation(),
            icon: vm.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
          InkWell(
            onTap: _openSearchScreen,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: _MinimalistMenuIcon(),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun bagian hero berisi suhu besar terkini, label deskripsi, dan label vertikal.
  Widget _buildHeroSection(
    BuildContext context,
    WeatherViewModel vm,
    WeatherData? weather,
  ) {
    if (vm.state == WeatherViewState.loading && weather == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 26, vertical: 34),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 14),
            Text(
              'Mengambil data cuaca terbaru...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    if (weather == null) {
      return const SizedBox(height: 110);
    }

    final current = weather.current;
    final tempText = current.temperature.round().toString();
    final heroLabel = WeatherCodeHelper.getHeroLabel(
      current.weatherCode,
      isDay: current.isDay,
    );
    final descId = WeatherCodeHelper.getDescriptionId(
      current.weatherCode,
      isDay: current.isDay,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Angka suhu besar semi-transparan dengan simbol derajat berlubang
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tempText,
                      style: const TextStyle(
                        fontSize: 102,
                        fontWeight: FontWeight.w200,
                        color: Color(0xD9FFFFFF),
                        height: 0.98,
                        letterSpacing: -5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xE6FFFFFF),
                            width: 3.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$descId  •  Terasa ${current.apparentTemperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Label kondisi cuaca vertikal di sisi kanan seperti referensi UI
          Padding(
            padding: const EdgeInsets.only(top: 14, right: 4),
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                heroLabel,
                style: const TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun konten panel putih di bawah gelombang (Cuaca Hari Ini, detail, dan 7 hari).
  Widget _buildSheetContent(
    BuildContext context,
    WeatherViewModel vm,
    WeatherData? weather,
  ) {
    if (vm.state == WeatherViewState.error && weather == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 46,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              vm.errorMessage ?? 'Gagal memuat data cuaca.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => vm.fetchWeatherForSelectedLocation(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (vm.state == WeatherViewState.empty && weather == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 44,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 10),
            Text(
              'Data cuaca untuk lokasi ini sedang kosong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'Cuaca Hari Ini',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (weather == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else ...[
            HourlyForecastStrip(hourlyList: weather.hourly),
            if (vm.state == WeatherViewState.error && vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.accentCoral,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 22),
            WeatherMetricsGrid(weatherData: weather),
            const SizedBox(height: 24),
            DailyForecastList(dailyList: weather.daily),
          ],
        ],
      ),
    );
  }
}

/// Ikon dua garis horizontal minimalis seperti pada kanan atas referensi UI.
class _MinimalistMenuIcon extends StatelessWidget {
  const _MinimalistMenuIcon();

  /// Membangun tampilan utama dengan [RefreshIndicator] dan [CustomScrollView].
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 15,
          height: 2.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 24,
          height: 2.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
