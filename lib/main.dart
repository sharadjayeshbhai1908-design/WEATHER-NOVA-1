import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/vehicle.dart';
import 'data/vehicle_data.dart';
import 'widgets/camera_scan_view.dart';
import 'widgets/vehicle_details_view.dart';
import 'widgets/chat_assistant_view.dart';
import 'widgets/mvp_docs_view.dart';
import 'widgets/app_logo.dart';

import 'services/gemini_service.dart';

void main() {
  runApp(const VehicleDetectorApp());
}

class VehicleDetectorApp extends StatelessWidget {
  const VehicleDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Vehicle Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.cyan,
          secondary: Colors.deepPurple,
          surface: Color(0xDDFFFFFF),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  Vehicle? _activeVehicle;
  final List<Vehicle> _scanHistory = [];
  final Set<String> _bookmarks = {};

  @override
  void initState() {
    super.initState();
    final xuv7xo = VehicleDatabase.vehicles.firstWhere((v) => v.id == 'mahindra_xuv_7xo_2026');
    _activeVehicle = null;
    // Pre-populate history with a few items to look good at start
    _scanHistory.addAll([
      xuv7xo,
      VehicleDatabase.vehicles.firstWhere((v) => v.id == 'hyundai_creta_2024'),
    ]);
    _bookmarks.add('mahindra_xuv_7xo_2026');
  }

  void _onVehicleDetected(Vehicle vehicle) {
    setState(() {
      // Add to history (avoid duplicates, move to end)
      _scanHistory.removeWhere((v) => v.id == vehicle.id);
      _scanHistory.add(vehicle);
      _activeVehicle = vehicle;
      // Stay on index 0 to show details view immediately
      _currentIndex = 0;
    });
  }

  void _selectVehicleFromOtherViews(Vehicle vehicle) {
    setState(() {
      _activeVehicle = vehicle;
      _currentIndex = 0; // Go to scanner tab to see details
    });
  }

  void _toggleBookmark(String vehicleId) {
    setState(() {
      if (_bookmarks.contains(vehicleId)) {
        _bookmarks.remove(vehicleId);
      } else {
        _bookmarks.add(vehicleId);
      }
    });
  }

  void _showSettingsDialog() async {
    final currentKey = await GeminiService.getApiKey() ?? GeminiService.defaultApiKey;
    final controller = TextEditingController(text: currentKey);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.cyan, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.cyan),
            const SizedBox(width: 12),
            Text(
              'Gemini AI Settings',
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To scan vehicles and chat with the AI, you need a Google Gemini API Key. It is 100% free.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Get a free API key at: aistudio.google.com',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Gemini API Key',
              style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(color: Colors.black87, fontSize: 13, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'Enter API Key (AIzaSy...)',
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade100,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black.withAlpha(20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyan),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              await GeminiService.clearApiKey();
              navigator.pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key reset to default key')),
                );
              }
            },
            child: const Text('Reset Default', style: TextStyle(color: Colors.black54, fontSize: 12)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontSize: 12)),
          ),
          TextButton(
            onPressed: () async {
              final newKey = controller.text.trim();
              if (newKey.isNotEmpty) {
                final navigator = Navigator.of(dialogContext);
                await GeminiService.saveApiKey(newKey);
                navigator.pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Custom API Key saved successfully!')),
                  );
                }
              }
            },
            child: const Text('Save Key', style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.cyan.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.cyan.withAlpha(50) : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? Colors.cyan.shade800 : Colors.black45,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.cyan.shade800 : Colors.black45,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    switch (_currentIndex) {
      case 0:
        // Scanner or Details
        if (_activeVehicle != null) {
          currentBody = VehicleDetailsView(
            vehicle: _activeVehicle!,
            onBack: () => setState(() => _activeVehicle = null),
            onSelectVehicle: _selectVehicleFromOtherViews,
          );
        } else {
          currentBody = CameraScanView(
            onVehicleDetected: _onVehicleDetected,
          );
        }
        break;
      case 1:
        currentBody = ChatAssistantView(currentVehicle: _activeVehicle);
        break;
      case 2:
        currentBody = const MvpDocsView();
        break;
      default:
        currentBody = const Center(child: Text('Coming Soon'));
    }

    return Stack(
      children: [
        // Premium tech background gradient & canvas
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF3F7FF), // Soft lavender blue
                  Color(0xFFE8EEFC), // Premium light ice blue
                  Color(0xFFFFFFFF), // Pure white
                ],
              ),
            ),
          ),
        ),
        // Decorative radial glow orbs
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            key: const ValueKey('glow-top-right'),
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.cyan.withAlpha(35),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            key: const ValueKey('glow-bottom-left'),
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple.withAlpha(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: const SizedBox.shrink(),
            ),
          ),
        ),

        // Scaffold UI
        Scaffold(
          appBar: _currentIndex != 0 || _activeVehicle == null
              ? AppBar(
                  title: Row(
                    children: [
                      const AppLogo(size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'AI Vehicle Detection',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    if (_activeVehicle != null && _currentIndex == 0)
                      IconButton(
                        icon: Icon(
                          _bookmarks.contains(_activeVehicle!.id)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: _bookmarks.contains(_activeVehicle!.id)
                              ? Colors.amber.shade700
                              : Colors.black87,
                        ),
                        onPressed: () => _toggleBookmark(_activeVehicle!.id),
                      ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.cyan),
                      onPressed: _showSettingsDialog,
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : null,
          body: SafeArea(child: currentBody),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.black.withAlpha(20),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.cyan.withAlpha(15),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.camera_enhance_outlined, Icons.camera_enhance, 'AI Scan'),
                      _buildNavItem(1, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Assistant'),
                      _buildNavItem(2, Icons.analytics_outlined, Icons.analytics, 'Roadmap'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
