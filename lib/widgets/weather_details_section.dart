// File: lib/widgets/weather_details_section.dart
// Fungsi: Menyediakan widget [WeatherMetricsGrid] (grid metrik cuaca terkini)
// dan [DailyForecastList] (daftar prakiraan cuaca 7 hari ke depan).

import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_code_helper.dart';
import 'weather_icon_widget.dart';

/// Menampilkan informasi tambahan cuaca terkini (kelembapan, kecepatan angin,
/// suhu dirasakan, curah hujan, peluang hujan maksimum, serta suhu min/maks).
class WeatherMetricsGrid extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherMetricsGrid({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final current = weatherData.current;
    final minTemp = weatherData.todayMinTemperature;
    final maxTemp = weatherData.todayMaxTemperature;

    final metrics = [
      _MetricItem(
        icon: Icons.water_drop_outlined,
        iconColor: AppTheme.accentRain,
        label: 'Kelembapan',
        value: '${current.relativeHumidity}%',
      ),
      _MetricItem(
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF5A9CF8),
        label: 'Kecepatan Angin',
        value: '${current.windSpeed.toStringAsFixed(1)} km/j',
      ),
      _MetricItem(
        icon: Icons.thermostat_outlined,
        iconColor: const Color(0xFFFF8A65),
        label: 'Terasa Seperti',
        value: '${current.apparentTemperature.round()}°C',
      ),
      _MetricItem(
        icon: Icons.umbrella_outlined,
        iconColor: const Color(0xFF6B6CE8),
        label: 'Peluang Hujan',
        value: '${weatherData.todayPrecipitationProbabilityMax}%',
      ),
      _MetricItem(
        icon: Icons.grain_rounded,
        iconColor: const Color(0xFF4DB6AC),
        label: 'Curah Hujan',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
      ),
      _MetricItem(
        icon: Icons.device_thermostat_rounded,
        iconColor: AppTheme.accentAmber,
        label: 'Min / Maks Hari Ini',
        value: (minTemp != null && maxTemp != null)
            ? '${minTemp.round()}° / ${maxTemp.round()}°'
            : '-',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Detail Kondisi Saat Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.25,
            ),
            itemBuilder: (context, index) {
              final item = metrics[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FD),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7ECF6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: item.iconColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Model data internal untuk satu kartu metrik cuaca pada [WeatherMetricsGrid].
class _MetricItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

/// Menampilkan prakiraan cuaca harian untuk beberapa hari ke depan (7 hari).
class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> dailyList;

  const DailyForecastList({
    super.key,
    required this.dailyList,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Prakiraan 7 Hari Ke Depan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FD),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE7ECF6)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyList.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFE5EAF4),
              ),
              itemBuilder: (context, index) {
                final day = dailyList[index];
                final dayName = DateFormatter.formatDayLabel(day.date, index);
                final shortDate = DateFormatter.formatShortDateId(day.date);
                final desc = WeatherCodeHelper.getDescriptionId(day.weatherCode);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              shortDate,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      WeatherIconWidget(
                        weatherCode: day.weatherCode,
                        isDay: true,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.water_drop,
                                  size: 11,
                                  color: AppTheme.accentRain,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${day.precipitationProbabilityMax}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.accentRain,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${day.minTemperature.round()}°',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '/',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                      Text(
                        '${day.maxTemperature.round()}°',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
