// File: lib/widgets/weather_icon_widget.dart
// Fungsi: Widget ikon cuaca ilustratif minimalis ([WeatherIconWidget]) yang
// memetakan kode cuaca WMO dan status siang/malam menjadi ikon visual.

import 'package:flutter/material.dart';

import '../utils/weather_code_helper.dart';

/// Ikon cuaca minimalis bergaya clean-outlined dan berwarna hangat
/// mengikuti estetika ikon pada panel "Weather Today" di referensi UI.
class WeatherIconWidget extends StatelessWidget {
  final int weatherCode;
  final bool isDay;
  final double size;

  const WeatherIconWidget({
    super.key,
    required this.weatherCode,
    this.isDay = true,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    final category = WeatherCodeHelper.getCategory(weatherCode);

    switch (category) {
      case WeatherCategory.clear:
        return isDay
            ? _SunIcon(size: size)
            : Icon(
                Icons.nightlight_round,
                size: size * 0.88,
                color: const Color(0xFF6B6CE8),
              );

      case WeatherCategory.partlyCloudy:
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: size * 0.06,
                left: size * 0.06,
                child: isDay
                    ? _SunIcon(size: size * 0.56)
                    : Icon(
                        Icons.nightlight_round,
                        size: size * 0.52,
                        color: const Color(0xFF7B7CEB),
                      ),
              ),
              Positioned(
                bottom: size * 0.08,
                right: size * 0.04,
                child: Icon(
                  Icons.cloud_outlined,
                  size: size * 0.72,
                  color: const Color(0xFF2B3245),
                ),
              ),
            ],
          ),
        );

      case WeatherCategory.cloudy:
      case WeatherCategory.fog:
        return Icon(
          Icons.cloud_outlined,
          size: size * 0.88,
          color: const Color(0xFF56627A),
        );

      case WeatherCategory.drizzle:
      case WeatherCategory.rain:
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: Icon(
                  Icons.cloud_outlined,
                  size: size * 0.76,
                  color: const Color(0xFF2B3245),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RainDrop(size: size * 0.14),
                    SizedBox(width: size * 0.08),
                    _RainDrop(size: size * 0.16),
                    SizedBox(width: size * 0.08),
                    _RainDrop(size: size * 0.14),
                  ],
                ),
              ),
            ],
          ),
        );

      case WeatherCategory.snow:
        return Icon(
          Icons.ac_unit_rounded,
          size: size * 0.84,
          color: const Color(0xFF5FA8F5),
        );

      case WeatherCategory.thunderstorm:
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: Icon(
                  Icons.cloud_outlined,
                  size: size * 0.76,
                  color: const Color(0xFF2B3245),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Icon(
                  Icons.bolt_rounded,
                  size: size * 0.44,
                  color: const Color(0xFFFFB300),
                ),
              ),
            ],
          ),
        );
    }
  }
}

/// Ikon matahari bercahaya dengan gradien kuning hangat untuk cuaca cerah siang hari.
class _SunIcon extends StatelessWidget {
  final double size;

  const _SunIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x33FFC107),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.66,
        height: size * 0.66,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD54F),
              Color(0xFFFFB300),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bentuk tetesan air hujan kecil untuk menyusun ikon hujan/gerimis.
class _RainDrop extends StatelessWidget {
  final double size;

  const _RainDrop({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.55,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: const Color(0xFF4FA3F7),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
