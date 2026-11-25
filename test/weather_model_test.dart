import 'package:flutter_test/flutter_test.dart';
import 'package:weather_responsi_app/models/location_model.dart';
import 'package:weather_responsi_app/models/weather_model.dart';
import 'package:weather_responsi_app/utils/weather_code_helper.dart';

void main() {
  group('Open-Meteo Model Parsing Tests', () {
    test('LocationModel.fromGeocodingJson parses city metadata correctly', () {
      final json = {
        'id': 1642911,
        'name': 'Purbalingga',
        'latitude': -7.3881,
        'longitude': 109.3639,
        'country': 'Indonesia',
        'country_code': 'ID',
        'admin1': 'Jawa Tengah',
        'timezone': 'Asia/Jakarta',
      };

      final location = LocationModel.fromGeocodingJson(json);

      expect(location.name, 'Purbalingga');
      expect(location.displayRegion, 'Jawa Tengah, Indonesia');
      expect(location.latitude, closeTo(-7.3881, 0.0001));
      expect(location.longitude, closeTo(109.3639, 0.0001));
    });

    test('WeatherData.fromJson parses current, hourly, and daily fields', () {
      final sampleJson = {
        'latitude': -7.3881,
        'longitude': 109.3639,
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-11-25T13:00',
          'temperature_2m': 30.4,
          'relative_humidity_2m': 72,
          'apparent_temperature': 34.1,
          'is_day': 1,
          'precipitation': 0.2,
          'weather_code': 2,
          'wind_speed_10m': 11.5,
        },
        'hourly': {
          'time': ['2026-11-25T13:00', '2026-11-25T14:00'],
          'temperature_2m': [30.4, 29.8],
          'weather_code': [2, 61],
          'precipitation_probability': [20, 65],
          'is_day': [1, 1],
        },
        'daily': {
          'time': ['2026-11-25', '2026-11-26'],
          'weather_code': [2, 63],
          'temperature_2m_max': [31.2, 29.5],
          'temperature_2m_min': [23.1, 22.8],
          'precipitation_probability_max': [65, 80],
        },
      };

      final weather = WeatherData.fromJson(sampleJson);

      expect(weather.current.temperature, 30.4);
      expect(weather.current.relativeHumidity, 72);
      expect(weather.current.apparentTemperature, 34.1);
      expect(weather.current.precipitation, 0.2);
      expect(weather.current.weatherCode, 2);
      expect(weather.current.windSpeed, 11.5);
      expect(weather.current.isDay, isTrue);
      expect(weather.hourly.length, 2);
      expect(weather.daily.length, 2);
      expect(weather.todayPrecipitationProbabilityMax, 65);
    });

    test('WeatherCodeHelper maps WMO codes to labels', () {
      expect(WeatherCodeHelper.getHeroLabel(0, isDay: true), 'Cerah');
      expect(WeatherCodeHelper.getHeroLabel(0, isDay: false), 'Malam Cerah');
      expect(WeatherCodeHelper.getDescriptionId(61), 'Hujan Ringan');
    });
  });
}
