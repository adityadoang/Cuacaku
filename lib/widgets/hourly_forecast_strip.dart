// File: lib/widgets/hourly_forecast_strip.dart
// Fungsi: Widget strip horizontal untuk menampilkan prakiraan cuaca per jam
// (ikon cuaca, jam, dan suhu) pada bagian "Cuaca Hari Ini".

import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'weather_icon_widget.dart';

/// Strip prakiraan per jam pada bagian "Weather Today" di panel bawah putih.
class HourlyForecastStrip extends StatelessWidget {
  final List<HourlyForecast> hourlyList;

  const HourlyForecastStrip({
    super.key,
    required this.hourlyList,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Data prakiraan per jam tidak tersedia.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: hourlyList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = hourlyList[index];
          final isNow = index == 0;
          return Container(
            width: 74,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: isNow
                  ? const Color(0xFFF0F5FF)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WeatherIconWidget(
                  weatherCode: item.weatherCode,
                  isDay: item.isDay,
                  size: 32,
                ),
                Text(
                  isNow ? 'Sekarang' : DateFormatter.formatHour24(item.time),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                    color: isNow
                        ? AppTheme.primarySky
                        : AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.temperature.round()}°',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
