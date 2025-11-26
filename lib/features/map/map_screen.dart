import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/forecast.dart';
import '../../data/providers/app_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Hotspot? _selectedHotspot;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final location =
            appState.currentLocation ?? const LatLng(37.7749, -122.4194);

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: 12,
                  onTap: (_, __) {
                    setState(() => _selectedHotspot = null);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.anglercatch.app',
                    tileBuilder: _darkTileBuilder,
                  ),
                  CircleLayer(circles: _buildHotspotCircles(appState.hotspots)),
                  MarkerLayer(
                    markers: [
                      _buildCurrentLocationMarker(location),
                      ..._buildHotspotMarkers(appState.hotspots),
                      ..._buildCatchMarkers(appState),
                    ],
                  ),
                ],
              ),
              _buildTopBar(context),
              if (_selectedHotspot != null)
                _buildHotspotCard(_selectedHotspot!),
              _buildMapControls(location),
            ],
          ),
        );
      },
    );
  }

  Widget _darkTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.3,
        0,
        0,
        0,
        0,
        0,
        0.3,
        0,
        0,
        0,
        0,
        0,
        0.4,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: tileWidget,
    );
  }

  List<CircleMarker> _buildHotspotCircles(List<Hotspot> hotspots) {
    return hotspots.map((hotspot) {
      final color = _getHotspotColor(hotspot.intensity);
      return CircleMarker(
        point: hotspot.location,
        radius: 80 * hotspot.intensity + 40,
        color: color.withAlpha(40),
        borderColor: color.withAlpha(120),
        borderStrokeWidth: 2,
      );
    }).toList();
  }

  Marker _buildCurrentLocationMarker(LatLng location) {
    return Marker(
      point: location,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.waterBlue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.waterBlue.withAlpha(100),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.my_location, color: Colors.white, size: 20),
      ),
    );
  }

  List<Marker> _buildHotspotMarkers(List<Hotspot> hotspots) {
    return hotspots.map((hotspot) {
      final color = _getHotspotColor(hotspot.intensity);
      return Marker(
        point: hotspot.location,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => setState(() => _selectedHotspot = hotspot),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(150),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phishing, color: Colors.white, size: 18),
                  Text(
                    '${hotspot.recentCatches}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _buildCatchMarkers(AppState appState) {
    final recentCatches = appState.catches.take(10);
    return recentCatches.map((catchRecord) {
      return Marker(
        point: catchRecord.location,
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.accentGold.withAlpha(200),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.star, color: Colors.white, size: 14),
        ),
      );
    }).toList();
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.map, color: AppColors.accentOrange),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Fishing Hotspots',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _buildLegendItem(AppColors.hotspotHigh, 'Hot'),
            const SizedBox(width: 8),
            _buildLegendItem(AppColors.hotspotMedium, 'Med'),
            const SizedBox(width: 8),
            _buildLegendItem(AppColors.hotspotLow, 'Low'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMapControls(LatLng location) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _MapControlButton(
            icon: Icons.add,
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
          ),
          const SizedBox(height: 8),
          _MapControlButton(
            icon: Icons.remove,
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
          ),
          const SizedBox(height: 8),
          _MapControlButton(
            icon: Icons.my_location,
            onPressed: () {
              _mapController.move(location, 14);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotCard(Hotspot hotspot) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getHotspotColor(hotspot.intensity).withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phishing,
                    color: _getHotspotColor(hotspot.intensity),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotspot.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${hotspot.recentCatches} catches recently',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${hotspot.averageScore.round()}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getHotspotColor(hotspot.intensity),
                      ),
                    ),
                    const Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: hotspot.species.map((species) {
                return Chip(
                  label: Text(species, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.surfaceElevated,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHotspotColor(double intensity) {
    if (intensity >= 0.7) return AppColors.hotspotHigh;
    if (intensity >= 0.4) return AppColors.hotspotMedium;
    return AppColors.hotspotLow;
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapControlButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 8),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary),
        onPressed: onPressed,
      ),
    );
  }
}
