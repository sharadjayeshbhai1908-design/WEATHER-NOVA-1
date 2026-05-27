import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../data/vehicle_data.dart';
import 'glass_card.dart';

class HistoryView extends StatelessWidget {
  final List<Vehicle> history;
  final Set<String> bookmarks;
  final Function(Vehicle) onSelectVehicle;
  final Function(String) onToggleBookmark;
  final VoidCallback onClearHistory;

  const HistoryView({
    super.key,
    required this.history,
    required this.bookmarks,
    required this.onSelectVehicle,
    required this.onToggleBookmark,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkedVehicles = VehicleDatabase.vehicles
        .where((v) => bookmarks.contains(v.id))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.cyanAccent,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            tabs: const [
              Tab(icon: Icon(Icons.history), text: 'Recent Scans'),
              Tab(icon: Icon(Icons.bookmark), text: 'Bookmarks'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildHistoryTab(context),
                _buildBookmarksTab(bookmarkedVehicles),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 52, color: Colors.white12),
            const SizedBox(height: 12),
            const Text(
              'No Scans Yet',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Scan preset vehicles to populate history',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${history.length} Scanned Items',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              TextButton.icon(
                onPressed: onClearHistory,
                icon: const Icon(Icons.delete_sweep, size: 16, color: Colors.redAccent),
                label: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final v = history[history.length - 1 - index]; // Show latest first
              final isBookmarked = bookmarks.contains(v.id);

              return FadeInPoint(
                delayMs: index * 40,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 16,
                    child: InkWell(
                      onTap: () => onSelectVehicle(v),
                      child: Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: v.localImageBytes != null
                                  ? Image.memory(
                                      v.localImageBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      v.imageUrls.isNotEmpty ? v.imageUrls.first : '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        color: Colors.white10,
                                        child: const Icon(Icons.broken_image, color: Colors.white30),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.brand,
                                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                                Text(
                                  v.model,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${v.year} • ${v.fuelType} • ${v.engineCC}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                                ),
                              ],
                            ),
                          ),

                          // Bookmark action button
                          IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? Colors.amber.shade400 : Colors.white60,
                            ),
                            onPressed: () => onToggleBookmark(v.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarksTab(List<Vehicle> bookmarkedVehicles) {
    if (bookmarkedVehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_outline, size: 52, color: Colors.white12),
            const SizedBox(height: 12),
            const Text(
              'No Bookmarks',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap bookmark on scan results to save here',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: bookmarkedVehicles.length,
      itemBuilder: (context, index) {
        final v = bookmarkedVehicles[index];

        return FadeInPoint(
          delayMs: index * 40,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              child: InkWell(
                onTap: () => onSelectVehicle(v),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: v.localImageBytes != null
                            ? Image.memory(
                                v.localImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                v.imageUrls.isNotEmpty ? v.imageUrls.first : '',
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.white10,
                                  child: const Icon(Icons.broken_image, color: Colors.white30),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.brand,
                            style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          Text(
                            v.model,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.priceRange,
                            style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.bookmark, color: Colors.amber.shade400),
                      onPressed: () => onToggleBookmark(v.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
