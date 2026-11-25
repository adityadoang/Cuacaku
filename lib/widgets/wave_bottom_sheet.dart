// File: lib/widgets/wave_bottom_sheet.dart
// Fungsi: Menyediakan [WaveTopClipper] untuk membentuk tepi gelombang organik
// pada transisi antara latar pemandangan dan panel putih "Cuaca Hari Ini".

import 'package:flutter/material.dart';

/// CustomClipper gelombang halus di bagian atas panel putih "Weather Today",
/// mengikuti lekukan organik pada referensi desain UI/UX.
class WaveTopClipper extends CustomClipper<Path> {
  const WaveTopClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    const waveHeight = 22.0;

    path.moveTo(0, waveHeight);
    path.quadraticBezierTo(
      size.width * 0.18,
      0,
      size.width * 0.45,
      waveHeight * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.76,
      waveHeight * 1.35,
      size.width,
      waveHeight * 0.45,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
