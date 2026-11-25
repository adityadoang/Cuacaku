
// Fungsi: Menyediakan model data lokasi kota ([LocationModel]) beserta adapter
// Hive ([LocationModelAdapter]) untuk serialisasi penyimpanan lokal.

import 'package:hive/hive.dart';

/// Model data lokasi kota hasil Open-Meteo Geocoding API
/// yang juga disimpan secara persisten di Hive Local Storage.
class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String admin1;
  final String timezone;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country = '',
    this.countryCode = '',
    this.admin1 = '',
    this.timezone = 'auto',
  });

  /// Lokasi default awal ketika pengguna baru pertama kali membuka aplikasi.
  static const LocationModel defaultLocation = LocationModel(
    id: 1642911,
    name: 'Jakarta',
    latitude: -6.21462,
    longitude: 106.84513,
    country: 'Indonesia',
    countryCode: 'ID',
    admin1: 'Jakarta',
    timezone: 'Asia/Jakarta',
  );

  /// Parsing JSON dari Open-Meteo Geocoding API.
  factory LocationModel.fromGeocodingJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final lon = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ??
          Object.hash(json['name'], lat.toStringAsFixed(3), lon.toStringAsFixed(3)),
      name: (json['name'] as String?)?.trim() ?? 'Unknown',
      latitude: lat,
      longitude: lon,
      country: (json['country'] as String?)?.trim() ?? '',
      countryCode: (json['country_code'] as String?)?.trim() ?? '',
      admin1: (json['admin1'] as String?)?.trim() ?? '',
      timezone: (json['timezone'] as String?)?.trim() ?? 'auto',
    );
  }

  /// Key unik untuk penyimpanan di Hive Box.
  String get storageKey =>
      '${id}_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}';

  /// Subtitle wilayah (mis. "Jawa Tengah, Indonesia").
  String get displayRegion {
    final parts = <String>[];
    if (admin1.isNotEmpty && admin1.toLowerCase() != name.toLowerCase()) {
      parts.add(admin1);
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    if (parts.isEmpty) {
      return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    }
    return parts.join(', ');
  }

  /// Mengonversi objek [LocationModel] ke format Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.id == id &&
        (other.latitude - latitude).abs() < 0.001 &&
        (other.longitude - longitude).abs() < 0.001;
  }

  @override
  int get hashCode => Object.hash(
        id,
        latitude.toStringAsFixed(3),
        longitude.toStringAsFixed(3),
      );
}

/// Manual Hive TypeAdapter untuk [LocationModel].
/// Ditulis langsung agar proyek siap dijalankan tanpa perlu build_runner.
class LocationModelAdapter extends TypeAdapter<LocationModel> {
  @override
  final int typeId = 0;

  /// Membaca data biner dari Hive dan merekonstruksinya menjadi [LocationModel].
  @override
  LocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationModel(
      id: (fields[0] as int?) ?? 0,
      name: (fields[1] as String?) ?? 'Unknown',
      latitude: (fields[2] as double?) ?? 0.0,
      longitude: (fields[3] as double?) ?? 0.0,
      country: (fields[4] as String?) ?? '',
      countryCode: (fields[5] as String?) ?? '',
      admin1: (fields[6] as String?) ?? '',
      timezone: (fields[7] as String?) ?? 'auto',
    );
  }

  /// Menulis seluruh field [LocationModel] ke dalam format biner Hive.
  @override
  void write(BinaryWriter writer, LocationModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.country)
      ..writeByte(5)
      ..write(obj.countryCode)
      ..writeByte(6)
      ..write(obj.admin1)
      ..writeByte(7)
      ..write(obj.timezone);
  }
}
