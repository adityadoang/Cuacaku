// File: lib/views/search_screen.dart
// Fungsi: Halaman pencarian dan pemilihan lokasi kota yang terhubung ke
// Open-Meteo Geocoding API serta daftar lokasi favorit dan riwayat Hive.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

/// Screen 2: Search / Location Screen (StatefulWidget).
/// Menyediakan pencarian kota via Open-Meteo Geocoding API, daftar hasil pencarian,
/// pemilihan kota, penyimpanan lokasi favorit, serta riwayat pencarian berbasis Hive.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// Memuat riwayat pencarian lokasi saat halaman pertama kali dibuka.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SearchViewModel>().loadHistory();
    });
  }

  /// Membersihkan controller input dan focus node saat halaman ditutup.
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Menyimpan kota terpilih ke riwayat, memperbarui lokasi aktif, dan kembali ke Home.
  Future<void> _selectCity(LocationModel location) async {
    final searchVm = context.read<SearchViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await searchVm.saveToHistory(location);
    searchVm.clearSearch();

    if (!mounted) return;
    // Pilih lokasi & mulai muat cuaca lalu kembali ke HomeScreen.
    weatherVm.selectLocation(location);
    Navigator.of(context).pop();
  }

  /// Mengubah status favorit suatu lokasi dan menampilkan notifikasi SnackBar.
  Future<void> _toggleFavorite(LocationModel location) async {
    final weatherVm = context.read<WeatherViewModel>();
    final added = await weatherVm.toggleFavorite(location);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${location.name} disimpan ke lokasi favorit'
              : '${location.name} dihapus dari lokasi favorit',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();
    final isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      appBar: AppBar(
        title: const Text('Cari Lokasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            searchVm.clearSearch();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {});
                searchVm.onQueryChanged(value);
              },
              onSubmitted: (value) {
                searchVm.searchCities(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari nama kota (mis. Yogyakarta, Tokyo)...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primarySky,
                ),
                suffixIcon: isSearching
                    ? IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          searchVm.clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: isSearching
                ? _buildSearchResults(searchVm, weatherVm)
                : _buildSavedCollections(searchVm, weatherVm),
          ),
        ],
      ),
    );
  }

  /// Membangun tampilan hasil pencarian kota berdasarkan state [SearchViewModel].
  Widget _buildSearchResults(
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    if (_searchController.text.trim().length < 2) {
      return const _EmptyStateView(
        icon: Icons.keyboard_alt_outlined,
        title: 'Ketik minimal 2 huruf',
        subtitle: 'Masukkan nama kota untuk mencari melalui Open-Meteo Geocoding API.',
      );
    }

    switch (searchVm.state) {
      case SearchViewState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2.6),
              SizedBox(height: 14),
              Text(
                'Mencari lokasi...',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        );

      case SearchViewState.error:
        return _EmptyStateView(
          icon: Icons.wifi_off_rounded,
          title: 'Pencarian Gagal',
          subtitle: searchVm.errorMessage ?? 'Tidak dapat terhubung ke server.',
          action: FilledButton.icon(
            onPressed: () => searchVm.searchCities(_searchController.text),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
          ),
        );

      case SearchViewState.empty:
        return _EmptyStateView(
          icon: Icons.location_off_outlined,
          title: 'Kota Tidak Ditemukan',
          subtitle:
              'Tidak ada lokasi yang cocok untuk "${_searchController.text.trim()}".',
        );

      case SearchViewState.idle:
      case SearchViewState.loaded:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: searchVm.results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final city = searchVm.results[index];
            final isFav = weatherVm.isFavorite(city);
            final isSelected = weatherVm.selectedLocation == city;
            return _LocationCard(
              location: city,
              isFavorite: isFav,
              isSelected: isSelected,
              onTap: () => _selectCity(city),
              onToggleFavorite: () => _toggleFavorite(city),
            );
          },
        );
    }
  }

  /// Membangun daftar lokasi favorit dan riwayat pencarian yang tersimpan di Hive.
  Widget _buildSavedCollections(
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    final favorites = weatherVm.favorites;
    final history = searchVm.history;

    if (favorites.isEmpty && history.isEmpty) {
      return const _EmptyStateView(
        icon: Icons.travel_explore_rounded,
        title: 'Belum Ada Lokasi Tersimpan',
        subtitle:
            'Cari nama kota di atas, lalu tandai favorit atau pilih kota untuk menyimpannya di Hive.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        // Bagian Lokasi Favorit (Hive)
        if (favorites.isNotEmpty) ...[
          const _SectionHeader(
            icon: Icons.favorite_rounded,
            iconColor: AppTheme.accentCoral,
            title: 'Lokasi Favorit',
          ),
          const SizedBox(height: 10),
          ...favorites.map((city) {
            final isSelected = weatherVm.selectedLocation == city;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LocationCard(
                location: city,
                isFavorite: true,
                isSelected: isSelected,
                onTap: () => _selectCity(city),
                onToggleFavorite: () => _toggleFavorite(city),
              ),
            );
          }),
          const SizedBox(height: 14),
        ],

        // Bagian Riwayat Pencarian (Hive)
        if (history.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.history_rounded,
            iconColor: AppTheme.primarySky,
            title: 'Riwayat Pencarian',
            trailing: TextButton(
              onPressed: () => searchVm.clearAllHistory(),
              child: const Text(
                'Hapus Semua',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...history.map((city) {
            final isFav = weatherVm.isFavorite(city);
            final isSelected = weatherVm.selectedLocation == city;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LocationCard(
                location: city,
                isFavorite: isFav,
                isSelected: isSelected,
                onTap: () => _selectCity(city),
                onToggleFavorite: () => _toggleFavorite(city),
                onRemoveHistory: () => searchVm.removeHistoryItem(city),
              ),
            );
          }),
        ],
      ],
    );
  }
}

/// Header bagian dengan ikon dan judul untuk memisahkan daftar favorit dan riwayat.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Kartu item lokasi kota dengan indikator status aktif, tombol favorit, dan hapus riwayat.
class _LocationCard extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onRemoveHistory;

  const _LocationCard({
    required this.location,
    required this.isFavorite,
    required this.isSelected,
    required this.onTap,
    required this.onToggleFavorite,
    this.onRemoveHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppTheme.primarySky : AppTheme.cardBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEAF2FF)
                      : const Color(0xFFF3F6FC),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: isSelected
                      ? AppTheme.primarySky
                      : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primarySky,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      location.displayRegion,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isFavorite ? 'Hapus Favorit' : 'Simpan Favorit',
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? AppTheme.accentCoral
                      : AppTheme.textSecondary,
                  size: 21,
                ),
              ),
              if (onRemoveHistory != null)
                IconButton(
                  tooltip: 'Hapus dari riwayat',
                  onPressed: onRemoveHistory,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSecondary,
                    size: 19,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tampilan status kosong atau error yang informatif pada halaman pencarian.
class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Icon(icon, size: 32, color: AppTheme.primarySky),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
