// File: lib/models/weather_model.dart
// Fungsi: Menyediakan model data cuaca lengkap ([WeatherData], [CurrentWeather],
// [HourlyForecast], [DailyForecast]) beserta parser JSON dari Open-Meteo API.

/// Model data lengkap hasil respons Open-Meteo Weather Forecast API.
class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  /// Mem-parsing JSON lengkap dari Open-Meteo API menjadi objek [WeatherData].
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>?;
    if (currentMap == null) {
      throw const FormatException('Data cuaca terkini (current) tidak ditemukan.');
    }

    final current = CurrentWeather.fromJson(currentMap);
    final hourly = _parseHourly(
      json['hourly'] as Map<String, dynamic>?,
      current.time,
    );
    final daily = _parseDaily(json['daily'] as Map<String, dynamic>?);

    return WeatherData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] as String?) ?? 'auto',
      current: current,
      hourly: hourly,
      daily: daily,
    );
  }

  /// Mengambil daftar prakiraan per jam mulai dari jam saat ini (maks 24 jam).
  static List<HourlyForecast> _parseHourly(
    Map<String, dynamic>? hourlyMap,
    DateTime currentTime,
  ) {
    if (hourlyMap == null) return const [];

    final times = (hourlyMap['time'] as List<dynamic>?) ?? const [];
    final temps = (hourlyMap['temperature_2m'] as List<dynamic>?) ?? const [];
    final codes = (hourlyMap['weather_code'] as List<dynamic>?) ?? const [];
    final rainProbs =
        (hourlyMap['precipitation_probability'] as List<dynamic>?) ?? const [];
    final isDays = (hourlyMap['is_day'] as List<dynamic>?) ?? const [];

    final count = times.length;
    final allHours = <HourlyForecast>[];

    for (int i = 0; i < count; i++) {
      final parsedTime = DateTime.tryParse(times[i].toString());
      if (parsedTime == null) continue;

      final temp =
          i < temps.length ? (temps[i] as num?)?.toDouble() ?? 0.0 : 0.0;
      final code = i < codes.length ? (codes[i] as num?)?.toInt() ?? 0 : 0;
      final rainProb =
          i < rainProbs.length ? (rainProbs[i] as num?)?.toInt() ?? 0 : 0;
      final isDay = i < isDays.length
          ? ((isDays[i] as num?)?.toInt() ?? 1) == 1
          : (parsedTime.hour >= 6 && parsedTime.hour < 18);

      allHours.add(
        HourlyForecast(
          time: parsedTime,
          temperature: temp,
          weatherCode: code,
          precipitationProbability: rainProb,
          isDay: isDay,
        ),
      );
    }

    // Filter mulai dari jam saat ini (dibulatkan ke awal jam) hingga 24 jam ke depan.
    final startHour = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
    );

    final upcoming = allHours
        .where((item) => !item.time.isBefore(startHour))
        .take(24)
        .toList();

    return upcoming.isNotEmpty ? upcoming : allHours.take(24).toList();
  }

  /// Mem-parsing daftar prakiraan cuaca harian (7 hari) dari field `daily`.
  static List<DailyForecast> _parseDaily(Map<String, dynamic>? dailyMap) {
    if (dailyMap == null) return const [];

    final times = (dailyMap['time'] as List<dynamic>?) ?? const [];
    final maxTemps =
        (dailyMap['temperature_2m_max'] as List<dynamic>?) ?? const [];
    final minTemps =
        (dailyMap['temperature_2m_min'] as List<dynamic>?) ?? const [];
    final rainProbs =
        (dailyMap['precipitation_probability_max'] as List<dynamic>?) ??
            const [];
    final codes = (dailyMap['weather_code'] as List<dynamic>?) ?? const [];

    final count = times.length;
    final result = <DailyForecast>[];

    for (int i = 0; i < count; i++) {
      final parsedDate = DateTime.tryParse(times[i].toString());
      if (parsedDate == null) continue;

      result.add(
        DailyForecast(
          date: parsedDate,
          maxTemperature: i < maxTemps.length
              ? (maxTemps[i] as num?)?.toDouble() ?? 0.0
              : 0.0,
          minTemperature: i < minTemps.length
              ? (minTemps[i] as num?)?.toDouble() ?? 0.0
              : 0.0,
          precipitationProbabilityMax: i < rainProbs.length
              ? (rainProbs[i] as num?)?.toInt() ?? 0
              : 0,
          weatherCode: i < codes.length ? (codes[i] as num?)?.toInt() ?? 0 : 0,
        ),
      );
    }

    return result;
  }

  /// Peluang hujan maksimum hari ini (berasal dari daily.precipitation_probability_max[0]).
  int get todayPrecipitationProbabilityMax =>
      daily.isNotEmpty ? daily.first.precipitationProbabilityMax : 0;

  /// Suhu maksimum hari ini (berasal dari `daily.temperature_2m_max[0]`).
  double? get todayMaxTemperature =>
      daily.isNotEmpty ? daily.first.maxTemperature : null;

  /// Suhu minimum hari ini (berasal dari `daily.temperature_2m_min[0]`).
  double? get todayMinTemperature =>
      daily.isNotEmpty ? daily.first.minTemperature : null;
}

/// Model data cuaca terkini (field `current` dari Open-Meteo).
class CurrentWeather {
  final DateTime time;
  final double temperature; // current.temperature_2m
  final int relativeHumidity; // current.relative_humidity_2m
  final double apparentTemperature; // current.apparent_temperature
  final double precipitation; // current.precipitation
  final int weatherCode; // current.weather_code
  final double windSpeed; // current.wind_speed_10m
  final bool isDay; // current.is_day

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
  });

  /// Mem-parsing objek `current` dari JSON Open-Meteo menjadi [CurrentWeather].
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final parsedTime =
        DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now();
    final isDayVal = (json['is_day'] as num?)?.toInt();

    return CurrentWeather(
      time: parsedTime,
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      isDay: isDayVal != null
          ? isDayVal == 1
          : (parsedTime.hour >= 6 && parsedTime.hour < 18),
    );
  }
}

/// Model prakiraan cuaca per jam untuk panel "Weather Today".
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
  final bool isDay;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.isDay,
  });
}

/// Model prakiraan cuaca harian (field `daily` dari Open-Meteo).
class DailyForecast {
  final DateTime date;
  final double maxTemperature; // daily.temperature_2m_max
  final double minTemperature; // daily.temperature_2m_min
  final int precipitationProbabilityMax; // daily.precipitation_probability_max
  final int weatherCode; // daily.weather_code

  const DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });
}
