// File: lib/utils/weather_code_helper.dart
// Fungsi: Memetakan kode cuaca WMO dari Open-Meteo ke kategori visual
// ([WeatherCategory]), label hero singkat, dan deskripsi cuaca Bahasa Indonesia.

/// Kategori visual cuaca untuk menentukan tema pemandangan dan ikon.
enum WeatherCategory {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
}

/// Helper untuk menerjemahkan WMO Weather Interpretation Code dari Open-Meteo.
class WeatherCodeHelper {
  const WeatherCodeHelper._();

  /// Mengelompokkan kode cuaca WMO menjadi kategori visual [WeatherCategory].
  static WeatherCategory getCategory(int code) {
    if (code == 0) return WeatherCategory.clear;
    if (code == 1 || code == 2) return WeatherCategory.partlyCloudy;
    if (code == 3) return WeatherCategory.cloudy;
    if (code == 45 || code == 48) return WeatherCategory.fog;
    if (code >= 51 && code <= 57) return WeatherCategory.drizzle;
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return WeatherCategory.rain;
    }
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return WeatherCategory.snow;
    }
    if (code >= 95 && code <= 99) return WeatherCategory.thunderstorm;
    return WeatherCategory.partlyCloudy;
  }

  /// Label singkat bergaya hero untuk teks vertikal di sisi kanan layar utama.
  static String getHeroLabel(int code, {bool isDay = true}) {
    switch (getCategory(code)) {
      case WeatherCategory.clear:
        return isDay ? 'Cerah' : 'Malam Cerah';
      case WeatherCategory.partlyCloudy:
        return 'Berawan Sebagian';
      case WeatherCategory.cloudy:
        return 'Langit Mendung';
      case WeatherCategory.fog:
        return 'Berkabut';
      case WeatherCategory.drizzle:
        return 'Gerimis Ringan';
      case WeatherCategory.rain:
        return 'Hujan';
      case WeatherCategory.snow:
        return 'Bersalju';
      case WeatherCategory.thunderstorm:
        return 'Badai Petir';
    }
  }

  /// Deskripsi lengkap kondisi cuaca dalam Bahasa Indonesia.
  static String getDescriptionId(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return isDay ? 'Cerah' : 'Cerah Berbintang';
      case 1:
        return 'Sebagian Besar Cerah';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
        return 'Berkabut';
      case 48:
        return 'Kabut Embun Beku';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Membeku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Membeku';
      case 71:
        return 'Salju Ringan';
      case 73:
        return 'Salju Sedang';
      case 75:
        return 'Salju Lebat';
      case 77:
        return 'Butiran Salju';
      case 80:
        return 'Hujan Lokal Ringan';
      case 81:
        return 'Hujan Lokal Sedang';
      case 82:
        return 'Hujan Lokal Deras';
      case 85:
      case 86:
        return 'Hujan Salju';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir & Hujan Es';
      default:
        return 'Berawan';
    }
  }
}
