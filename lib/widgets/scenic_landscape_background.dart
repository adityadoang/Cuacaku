// File: lib/widgets/scenic_landscape_background.dart
// Fungsi: Widget latar belakang pemandangan ilustratif berbasis aset gambar
// yang otomatis menyesuaikan kondisi cuaca dan waktu siang/malam.

import 'package:flutter/material.dart';

import '../utils/weather_code_helper.dart';

/// Latar belakang pemandangan perbukitan ilustratif berbasis aset gambar
/// yang menyesuaikan kondisi cuaca (siang cerah, malam berbintang, hujan/mendung).
class ScenicLandscapeBackground extends StatelessWidget {
  final int weatherCode;
  final bool isDay;

  const ScenicLandscapeBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
  });

  /// Menentukan path aset gambar latar sesuai kategori cuaca dan waktu siang/malam.
  String _resolveAssetPath(WeatherCategory category) {
    if (category == WeatherCategory.rain ||
        category == WeatherCategory.drizzle ||
        category == WeatherCategory.thunderstorm ||
        category == WeatherCategory.snow) {
      return 'assets/images/bg_rainy.jpg';
    }
    if (!isDay) {
      return 'assets/images/bg_night_clear.jpg';
    }
    return 'assets/images/bg_day_clear.jpg';
  }

  /// Memberikan warna tint halus untuk kondisi mendung, berkabut, atau berawan.
  Color? _resolveOverlayTint(WeatherCategory category) {
    if (category == WeatherCategory.cloudy || category == WeatherCategory.fog) {
      return isDay
          ? const Color(0x385E7CA6)
          : const Color(0x331B2447);
    }
    if (category == WeatherCategory.partlyCloudy && isDay) {
      return const Color(0x146E9AD4);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final category = WeatherCodeHelper.getCategory(weatherCode);
    final assetPath = _resolveAssetPath(category);
    final overlayTint = _resolveOverlayTint(category);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: Stack(
        key: ValueKey<String>('$assetPath-$overlayTint'),
        fit: StackFit.expand,
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            gaplessPlayback: true,
          ),
          if (overlayTint != null)
            ColoredBox(color: overlayTint),
        ],
      ),
    );
  }
}
