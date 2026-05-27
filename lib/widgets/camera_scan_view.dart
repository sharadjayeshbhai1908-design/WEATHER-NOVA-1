import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vehicle.dart';
import '../services/gemini_service.dart';

class CameraScanView extends StatefulWidget {
  final Function(Vehicle) onVehicleDetected;

  const CameraScanView({super.key, required this.onVehicleDetected});

  @override
  State<CameraScanView> createState() => _CameraScanViewState();
}

class _CameraScanViewState extends State<CameraScanView> with TickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _boxAnimationController;
  bool _isScanning = false;
  String _scanStatus = 'Ready to scan';
  double _scanProgress = 0.0;
  String _aiModuleStatus = 'Idle';

  // Multi-image fields
  final List<Uint8List> _pickedImages = [];
  static const int _maxImages = 5;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scanController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _scanController.forward();
        }
      });

    _boxAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadApiKey();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _boxAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final key = await GeminiService.getApiKey();
    if (key != null && mounted) {
      setState(() {
        _apiKey = key;
      });
    }
  }

  // Pick an image from Camera or Gallery and ADD to the list
  Future<void> _pickImage(ImageSource source) async {
    if (_pickedImages.length >= _maxImages) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum $_maxImages images allowed'),
            backgroundColor: Colors.orangeAccent.shade700,
          ),
        );
      }
      return;
    }

    try {
      final picker = ImagePicker();

      if (source == ImageSource.gallery) {
        // Allow picking multiple images from gallery
        final List<XFile> images = await picker.pickMultiImage(
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );
        if (images.isEmpty) return;

        final remaining = _maxImages - _pickedImages.length;
        final toAdd = images.take(remaining);

        for (final image in toAdd) {
          final bytes = await image.readAsBytes();
          _pickedImages.add(bytes);
        }
        if (mounted) setState(() {});
      } else {
        // Camera: single shot
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80,
        );
        if (image == null) return;
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImages.add(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: $e')),
        );
      }
    }
  }

  // Remove a specific image
  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  // Start scanning with all collected images
  Future<void> _startMultiImageScan() async {
    if (_pickedImages.isEmpty) return;

    final apiKeyToUse = _apiKey ?? GeminiService.defaultApiKey;

    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
      _aiModuleStatus = 'Handshaking Vision Core...';
      _scanStatus = 'Sending ${_pickedImages.length} image(s) to Gemini AI...';
    });
    _scanController.forward();

    final timer1 = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _scanProgress = 0.35;
        _aiModuleStatus = 'Gemini AI Vision Analysis';
        _scanStatus = 'Analyzing vehicle from ${_pickedImages.length} angle(s)...';
      });
    });

    final timer2 = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _scanProgress = 0.75;
        _aiModuleStatus = 'Extracting Specs & Diagnostics';
        _scanStatus = 'Structuring parameters and valuation...';
      });
    });

    try {
      final Vehicle detectedVehicle = await GeminiService.analyzeVehicleImages(
        _pickedImages,
        apiKeyToUse,
      );
      timer1.cancel();
      timer2.cancel();

      if (!mounted) return;
      setState(() {
        _scanProgress = 1.0;
        _aiModuleStatus = 'Scan Complete';
        _scanStatus = 'Identified: ${detectedVehicle.brand} ${detectedVehicle.model}!';
      });

      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _isScanning = false;
          _pickedImages.clear();
          _scanController.stop();
          _scanController.reset();
        });
        widget.onVehicleDetected(detectedVehicle);
      });
    } catch (e) {
      timer1.cancel();
      timer2.cancel();
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanController.stop();
        _scanController.reset();
      });

      // Detect network vs API errors
      final errorStr = e.toString().toLowerCase();
      final bool isNetworkError = errorStr.contains('socketexception') ||
          errorStr.contains('failed host lookup') ||
          errorStr.contains('no address associated') ||
          errorStr.contains('connection refused') ||
          errorStr.contains('network is unreachable') ||
          errorStr.contains('timed out') ||
          errorStr.contains('handshake');

      final String title = isNetworkError ? 'No Internet Connection' : 'Inference Failed';
      final IconData icon = isNetworkError ? Icons.wifi_off : Icons.error_outline;
      final String message = isNetworkError
          ? 'Your device is not connected to the internet.\n\nThe AI scanner needs an active WiFi or mobile data connection to analyze vehicle images.\n\nPlease:\n1. Turn ON WiFi or Mobile Data\n2. Check if you can open any website\n3. Tap "Retry" once connected'
          : 'Failed to recognize the vehicle.\n\nError: $e\n\nTips:\n1. Ensure images are clear and focused on the vehicle.\n2. Try uploading a different angle.';

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF0F0F0F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isNetworkError ? Colors.orangeAccent : Colors.redAccent, width: 1.5),
          ),
          title: Row(
            children: [
              Icon(icon, color: isNetworkError ? Colors.orangeAccent : Colors.redAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Dismiss', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            if (_pickedImages.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _startMultiImageScan(); // Retry with same images
                },
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: isNetworkError ? Colors.orangeAccent : Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Visual Scanner Portal
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withAlpha(12),
                  blurRadius: 30,
                  spreadRadius: -2,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(130),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withAlpha(200), width: 1.5),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: _pickedImages.isEmpty
                                ? _buildEmptyState()
                                : _buildImageGrid(),
                          ),

                          // Glowing Corner brackets & cyber grid overlay
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: AnimatedBuilder(
                                  animation: _boxAnimationController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: ScannerBoxPainter(
                                        animationValue: _boxAnimationController.value,
                                        color: _isScanning 
                                            ? Colors.deepPurple.shade300 
                                            : Colors.cyan,
                                        isScanning: _isScanning,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // Scanning overlay
                          if (_isScanning)
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _scanLineAnimation,
                                builder: (context, child) {
                                  return Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(170),
                                          borderRadius: BorderRadius.circular(26),
                                        ),
                                      ),
                                      // Laser line sweeping
                                      Positioned(
                                        top: _scanLineAnimation.value * (constraints.maxHeight - 50) + 15,
                                        left: 24,
                                        right: 24,
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: Colors.cyan,
                                                borderRadius: BorderRadius.circular(1.5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.cyan.withAlpha(220),
                                                    blurRadius: 15,
                                                    spreadRadius: 2.5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 35,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.cyan.withAlpha(45),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Rotating glow ring
                                            Container(
                                              width: 80,
                                              height: 80,
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withAlpha(200),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.cyan.withAlpha((70 * _scanLineAnimation.value).round()),
                                                    blurRadius: 20,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: const CircularProgressIndicator(
                                                color: Colors.cyan,
                                                strokeWidth: 3.0,
                                              ),
                                            ),
                                            const SizedBox(height: 28),
                                            Text(
                                              _aiModuleStatus,
                                              style: TextStyle(
                                                color: Colors.cyan.shade900,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 24),
                                              child: Text(
                                                _scanStatus,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              width: 160,
                                              height: 4,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(2),
                                                child: LinearProgressIndicator(
                                                  value: _scanProgress,
                                                  backgroundColor: Colors.black12,
                                                  color: Colors.cyan,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        // Image count + clear all
        if (_pickedImages.isNotEmpty && !_isScanning)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_pickedImages.length} / $_maxImages images added',
                  style: GoogleFonts.outfit(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _pickedImages.clear()),
                  icon: const Icon(Icons.delete_sweep, size: 16, color: Colors.redAccent),
                  label: Text('Clear All', style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              // Camera button
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.cyan.withAlpha(15),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.cyan.withAlpha(50),
                      width: 1.2,
                    ),
                  ),
                  child: TextButton.icon(
                    onPressed: _isScanning ? null : () => _pickImage(ImageSource.camera),
                    icon: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.cyan, Colors.purpleAccent],
                      ).createShader(bounds),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                    label: Text(
                      'Camera',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Gallery button
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.purple.withAlpha(15),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.purple.withAlpha(50),
                      width: 1.2,
                    ),
                  ),
                  child: TextButton.icon(
                    onPressed: _isScanning ? null : () => _pickImage(ImageSource.gallery),
                    icon: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.purpleAccent, Colors.cyan],
                      ).createShader(bounds),
                      child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
                    ),
                    label: Text(
                      'Gallery',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scan Vehicle Button (only when images are loaded)
        if (_pickedImages.isNotEmpty && !_isScanning)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.cyan, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _startMultiImageScan,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
                  label: Text(
                    'Analyze Vehicle  (${_pickedImages.length} photo${_pickedImages.length > 1 ? 's' : ''})',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Bottom spacer when no images
        if (_pickedImages.isEmpty && !_isScanning)
          const SizedBox(height: 12),
      ],
    );
  }

  // Empty state placeholder
  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.cyan.withAlpha(25),
            Colors.white.withAlpha(80),
          ],
          radius: 1.2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _boxAnimationController,
              builder: (context, child) {
                final double scale = 0.96 + (_boxAnimationController.value * 0.08); // Scale pulses between 0.96 and 1.04
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating HUD radar ring
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: RadarRingPainter(
                          animationValue: _boxAnimationController.value,
                          color: Colors.cyan,
                        ),
                      ),
                    ),
                    // Centered pulsing icon container
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyan.withAlpha(20),
                          border: Border.all(color: Colors.cyan.withAlpha(60), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withAlpha((15 * _boxAnimationController.value).round()),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.cyan, Colors.purpleAccent],
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.center_focus_strong,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Add Vehicle Photos',
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                'Capture or upload images from multiple angles (front, side, rear) for a complete mechanic-grade AI diagnostic scan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grid of picked images with remove buttons
  Widget _buildImageGrid() {
    return Container(
      color: Colors.black,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _pickedImages.length == 1 ? 1 : 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: _pickedImages.length == 1 ? 16 / 10 : 1.0,
        ),
        itemCount: _pickedImages.length,
        itemBuilder: (context, index) {
          final angleLabels = ['Front', 'Right', 'Rear', 'Left', 'Top'];
          final label = index < angleLabels.length ? angleLabels[index] : 'Photo ${index + 1}';

          return Stack(
            fit: StackFit.expand,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  _pickedImages[index],
                  fit: BoxFit.cover,
                ),
              ),
              // Angle label at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withAlpha(200),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Remove button
              if (!_isScanning)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 0.8),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ScannerBoxPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isScanning;

  ScannerBoxPainter({
    required this.animationValue,
    required this.color,
    required this.isScanning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Draw subtle cyber grid
    final Paint gridPaint = Paint()
      ..color = color.withAlpha(isScanning ? 35 : 15)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    
    const int rows = 8;
    const int cols = 6;
    final double rowHeight = h / rows;
    final double colWidth = w / cols;
    
    // Horizontal lines
    for (int i = 1; i < rows; i++) {
      canvas.drawLine(Offset(0, i * rowHeight), Offset(w, i * rowHeight), gridPaint);
    }
    // Vertical lines
    for (int i = 1; i < cols; i++) {
      canvas.drawLine(Offset(i * colWidth, 0), Offset(i * colWidth, h), gridPaint);
    }
    
    // Draw corner brackets that slide/breathe
    final double breathe = animationValue; // 0.0 to 1.0
    final double slideOffset = 2.0 + (breathe * 6.0); // slides between 2 and 8 pixels
    final double len = math.min(w, h) * 0.08; // bracket line length
    final double stroke = 3.0;

    final Paint bracketPaint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-Left corner
    canvas.drawLine(Offset(slideOffset, slideOffset), Offset(slideOffset + len, slideOffset), bracketPaint);
    canvas.drawLine(Offset(slideOffset, slideOffset), Offset(slideOffset, slideOffset + len), bracketPaint);

    // Top-Right corner
    canvas.drawLine(Offset(w - slideOffset, slideOffset), Offset(w - slideOffset - len, slideOffset), bracketPaint);
    canvas.drawLine(Offset(w - slideOffset, slideOffset), Offset(w - slideOffset, slideOffset + len), bracketPaint);

    // Bottom-Left corner
    canvas.drawLine(Offset(slideOffset, h - slideOffset), Offset(slideOffset + len, h - slideOffset), bracketPaint);
    canvas.drawLine(Offset(slideOffset, h - slideOffset), Offset(slideOffset, h - slideOffset - len), bracketPaint);

    // Bottom-Right corner
    canvas.drawLine(Offset(w - slideOffset, h - slideOffset), Offset(w - slideOffset - len, h - slideOffset), bracketPaint);
    canvas.drawLine(Offset(w - slideOffset, h - slideOffset), Offset(w - slideOffset, h - slideOffset - len), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerBoxPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.color != color || 
           oldDelegate.isScanning != isScanning;
  }
}

class RadarRingPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  RadarRingPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    
    // Draw outer dashed ring
    final Paint paint = Paint()
      ..color = color.withAlpha(60)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    const int dashCount = 24;
    final double dashWidth = 0.08; // radians
    final double spaceWidth = (2 * math.pi / dashCount) - dashWidth;
    
    double startAngle = animationValue * 2 * math.pi; // rotates based on animation
    
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + 12),
        startAngle,
        dashWidth,
        false,
        paint,
      );
      startAngle += dashWidth + spaceWidth;
    }
    
    // Draw targeting tick lines
    final Paint tickPaint = Paint()
      ..color = color.withAlpha(120)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
      
    for (int i = 0; i < 4; i++) {
      final double angle = startAngle + (i * math.pi / 2);
      final Offset p1 = Offset(
        center.dx + (radius + 2) * math.cos(angle),
        center.dy + (radius + 2) * math.sin(angle),
      );
      final Offset p2 = Offset(
        center.dx + (radius + 8) * math.cos(angle),
        center.dy + (radius + 8) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RadarRingPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}

