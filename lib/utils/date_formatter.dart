// File: lib/utils/date_formatter.dart
// Fungsi: Menyediakan helper pemformatan tanggal, hari, dan jam dalam Bahasa
// Indonesia tanpa ketergantungan pada package eksternal.

/// Formatter tanggal dan waktu dalam Bahasa Indonesia tanpa ketergantungan versi intl.
class DateFormatter {
  const DateFormatter._();

  static const List<String> _shortMonthsId = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _daysId = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  /// Format header Home Screen: "Hari Ini, 25 Nov 13:10"
  static String formatHeroDateTime(DateTime dt) {
    final month = _shortMonthsId[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return 'Hari Ini, ${dt.day} $month $hour:$minute';
  }

  /// Format jam 24 jam pada strip prakiraan per jam: "13:00"
  static String formatHour24(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    return '$hour:00';
  }

  /// Format nama hari untuk prakiraan 7 hari ke depan (Bahasa Indonesia).
  static String formatDayLabel(DateTime date, int index) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';
    return _daysId[date.weekday - 1];
  }

  /// Format tanggal singkat: "25 Nov"
  static String formatShortDateId(DateTime date) {
    return '${date.day} ${_shortMonthsId[date.month - 1]}';
  }
}
